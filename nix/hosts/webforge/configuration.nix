{ pkgs, config, lib, ... }: {
  imports = [
    ../../common
    ./hardware-configuration.nix
    ./networking.nix

    ./backup.nix
    ./web-landing-page.nix
    ./forgejo.nix
    ./mailserver.nix
    ./postgresql.nix
  ];

  networking.hostName = "webforge";
  networking.domain = "of.tahoe-lafs.org";

  # Open the ports required for a web server
  networking.firewall = {
    allowedTCPPorts = [
      80
      443
    ];
    allowedUDPPorts = [
      443
    ];
  };

  # Enable Nginx with common settings
  services.nginx = {
    enable = true;

    # Apply recommended settings
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Only allow PFS-enabled ciphers with AES256:
    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";
  };

  system.stateVersion = "23.11";
}
