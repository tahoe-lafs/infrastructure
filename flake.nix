{
  inputs = {
    # The nixpkgs channels we want to consume
    nixpkgs-24_05.url = "github:NixOS/nixpkgs/nixos-24.05-small";
    nixpkgs-24_11.url = "github:NixOS/nixpkgs/nixos-24.11-small";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    # Some links to the above channels for consistent naming in outputs
    nixpkgs-oldstable.follows = "nixpkgs-24_05";
    nixpkgs.follows = "nixpkgs-24_11";

    # Extra inputs for modules leaving outside nixpkgs
    sops-nix = {
      url = "github:Mic92/sops-nix";
      # Flip those when the last systems can start using this module
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-24.05";
      # Flip those when the last systems can start using this module
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-24_05.follows = "nixpkgs-oldstable";
    };
  };
  outputs = { self, nixpkgs, nixpkgs-oldstable, nixpkgs-unstable, ... }@attrs:
    let
      system = "x86_64-linux";
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
    in {
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
