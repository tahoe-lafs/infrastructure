{ config, pkgs, simple-nixos-mailserver, ... }: {
  imports = [
    simple-nixos-mailserver.nixosModule
  ];

  sops = {
    secrets = {
      mailserver-noreply-hashed-password = {
        owner = "dovenull";
        group = "dovenull";
      };
    };
  };

  mailserver = {
    enable = true;
    fqdn = "mail.87b59b92.nip.io";
    domains = [
      "87b59b92.nip.io"
    ];
    useFsLayout = true;
    hierarchySeparator = "/";

    # A list of all login accounts. To create the password hashes, use
    # nix-shell -p apacheHttpd --run 'htpasswd -nB ""' | cut -d: -f2
    loginAccounts = {
      "noreply@87b59b92.nip.io" = {
        hashedPasswordFile = config.sops.secrets.mailserver-noreply-hashed-password.path;
        sendOnly = true;
        aliases = [
          "noreply@forge.87b59b92.nip.io"
        ];
      };
    };

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    certificateScheme = "acme-nginx";
    rebootAfterKernelUpgrade.enable = true;
  };
}
