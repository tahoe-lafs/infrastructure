{ config, pkgs, simple-nixos-mailserver, ... }: {
  imports = [
    simple-nixos-mailserver.nixosModule
  ];

  # Only to send email from Forgejo
  mailserver = {
    enable = true;
    fqdn = "forge.of.tahoe-lafs.org";
    domains = [
      "forge.of.tahoe-lafs.org"
    ];

    # Explicitely disable IMAP and POP from dovecot
    enableImap = false;
    enableImapSsl = false;
    enablePop3 = false;
    enablePop3Ssl = false;
    # Keep only SMTP w/o (START)TLS to relay local emails via postfix
    enableSubmission = false;
    enableSubmissionSsl = false;

    # Only one sending account
    loginAccounts = {
      "noreply@forge.of.tahoe-lafs.org" = {
        # No need of password when using localhost
        hashedPassword = "";
        sendOnly = true;
      };
    };
  };

  # Ensure only local relaying (for now)
  services.postfix = {
    extraConfig = ''
      inet_interfaces = 127.0.0.1
    '';
    networks = [ "127.0.0.0/8" ];
  };
}
