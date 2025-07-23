{
  inputs = {
    # The nixpkgs channels we want to consume
    nixpkgs-24_05.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-24_11.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Some links to the above channels for consistent naming in outputs
    nixpkgs-oldstable.follows = "nixpkgs-24_05";
    nixpkgs.follows = "nixpkgs-24_11";

    # Extra inputs for modules leaving outside nixpkgs
    flake-compat = {
      url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      # Flip those when the last systems can start using this module
      inputs.nixpkgs.follows = "nixpkgs";
    };
    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-24.11";
      # Flip those when the last systems can start using this module
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-24_11.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixpkgs-oldstable, nixpkgs-unstable, ... }@attrs:
    let
      # Add overlays to access old and unstable packages
      overlay-oldstable = final: prev: {
        oldstable = nixpkgs-oldstable.legacyPackages.${prev.system};
      };
      overlay-unstable = final: prev: {
        unstable = nixpkgs-unstable.legacyPackages.${prev.system};
      };
      # Our function to generate an attrset of nixosConfiguration based on
      # a specific nixpkgs (e.g.: oldstable) and a list of sysname
      mkSystemConfigurations = nixpkgs: sysnames:
        nixpkgs.lib.attrsets.genAttrs sysnames (sysname: nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = attrs;
          modules = [
            ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-oldstable overlay-unstable ]; })
            { system.name = sysname; }
            ./nix/hosts/${sysname}/configuration.nix
          ];
        });
      # The devShells of this flake only support one system = "x86_64-linux"
      # FIXME: could it support more (flake-utils does not help!)?
      system = "x86_64-linux";
      # Unfortunately, the hetznerdns provider is no longer maintain
      # We need an overlay to use the more recent fork,
      # until we get a better version from upstream (issue w/ TXT records)
      tofuOverlay = final: prev: {
        terraform-providers = prev.terraform-providers // {
          hetznerdns = prev.terraform-providers.hetznerdns.overrideAttrs (old: rec {
            name = "terraform-provider-hetznerdns-${version}";
            version = "3.4.6";
            src = prev.fetchFromGitHub {
              owner = "germanbrew";
              repo = "terraform-provider-hetznerdns";
              rev = "v${version}";
              sha256 = "40u9K19nVZadMWj0azKrx99gMSKk83CXzjM/HGZCr/w=";
            };
            owner = "${src.owner}";
            homepage = "https://registry.terraform.io/providers/${src.owner}/hetznerdns";
            provider-source-address = "registry.terraform.io/${src.owner}/hetznerdns";
            postInstall = "dir=$out/libexec/terraform-providers/registry.terraform.io/${src.owner}/hetznerdns/${version}/\${GOOS}_\${GOARCH}\nmkdir -p \"$dir\"\nmv $out/bin/* \"$dir/terraform-provider-$(basename registry.terraform.io/${src.owner}/hetznerdns)_${version}\"\nrmdir $out/bin\n";
            vendorHash = "sha256-9ufpWt+yLIvjjRuuUxzk1UM7CaYEKCeORdjO9P45moc=";
          });
        };
      };
      # The following devShell needs OpenToFu from NixOS 25.05
      # TODO: switch to stable after the next upgrade
      pkgs = import nixpkgs-unstable { inherit system; overlays = [ tofuOverlay ]; };
    in {
      devShells."${system}".default = pkgs.mkShell {
        packages = [
          pkgs.gnupg
          pkgs.sops
          (pkgs.opentofu.withPlugins (plugins: [
            plugins.hcloud
            plugins.hetznerdns
          ]))
        ];
        shellHook = ''
          # Print the version of some of the software used by this shell
          echo -n "gpg: v"&& ${pkgs.gnupg}/bin/gpg --version | head -1 | grep -Po '\d+\.\d+\.\d+'
          echo -n "sops: " && ${pkgs.sops}/bin/sops --version | head -1 | grep -Po '\d+\.\d+\.\d+'
          # Select the default password store to use
          export PASSWORD_STORE_DIR="secrets"
          # Inspect the current GnuPG config and save some data for later
          SOCKETAGENT_CUR="$(gpgconf --list-dirs agent-socket)"
          # Use a temporary key store for this shell to not alter the user's one
          export GNUPGHOME="$(mktemp --directory --tmpdir=$TMPDIR gnupg_home.XXXXXXXXXX)"
          # Prepare a minimal configuration, and avoid to fire a new agent
          umask 077 \
          && echo "no-autostart" >> "$GNUPGHOME/gpg.conf"
          SOCKETAGENT_TMP="$(gpgconf --list-dirs agent-socket)"
          # Re-use the current agent sockets for this temporary session
          ln -s "$SOCKETAGENT_CUR" "$SOCKETAGENT_TMP"
          # Import the relevant public-keys used by SOPS into the temporary GnuPG key store
          while read KEY_NAME KEY_ID; do
            gpg --quiet --import "$PASSWORD_STORE_DIR/.public-keys/$KEY_NAME.asc" \
            || echo "WARNING: Could not import $PASSWORD_STORE_DIR/.public-keys/$KEY_NAME.asc"
            gpg --quiet --import-ownertrust <(echo "$(\
              gpg --quiet --with-colons --fingerprint $KEY_ID | grep fpr | head -1 | cut -d ':' -f 10\
            ):6:") > /dev/null 2>&1
          done < <(grep -vP '(^\s*#)' .sops.yaml | grep -Po '(?<=\&)[^\s]+ [0-9a-fA-F]{40}')
        '';
      };
      nixosConfigurations =
        # Merge the nixosConfigurations generated for each of our nixpkgs
        mkSystemConfigurations nixpkgs [
          "webforge"
        ] //
        mkSystemConfigurations nixpkgs-oldstable [
          # empty for now: use for smooth upgrade
        ] //
        mkSystemConfigurations nixpkgs-unstable [
          # maybe "testgrid" soon
        ];
      };
}
