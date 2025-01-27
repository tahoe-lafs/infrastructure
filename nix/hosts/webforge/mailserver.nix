{ config, pkgs, simple-nixos-mailserver, ... }: {
  imports = [
    simple-nixos-mailserver.nixosModule
  ];

  sops = {
    secrets = {
      mail-noreply-hashed-password = {
        owner = "dovenull";
        group = "dovenull";
      };
    };
  };

  mailserver = {
    enable = true;
    fqdn = "mail.tahoe-lafs.org";
    domains = [
      "tahoe-lafs.org"
    ];
    useFsLayout = true;
    hierarchySeparator = "/";

    # A list of all login accounts. To create the password hashes, use
    # nix-shell -p apacheHttpd --run 'htpasswd -nB ""' | cut -d: -f2
    loginAccounts = {
      "noreply@tahoe-lafs.org" = {
        hashedPasswordFile = config.sops.secrets.mail-noreply-hashed-password.path;
        sendOnly = true;
        aliases = [
          "noreply@webforge.tahoe-lafs.org"
        ];
      };
    };

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    certificateScheme = "acme-nginx";
    rebootAfterKernelUpgrade.enable = true;
  };
}
