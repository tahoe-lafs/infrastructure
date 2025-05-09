{ pkgs, config, lib, ... }: {
  imports = [
    ../../common
    ./hardware-configuration.nix
    ./networking.nix

    ./forgejo-runner.nix
    ./forgejo.nix
    ./mailserver.nix
    ./postgresql.nix
    ./websites.nix
  ];

  networking.hostName = "webforge";
  networking.domain = "tahoe-lafs.org";

  # Enable firewall with the required ports
  networking.firewall = {
    enable = true;
    allowPing = false;
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
