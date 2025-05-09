{ pkgs, config, lib, ... }: {
  imports = [
    ../../common
    ./hardware-configuration.nix
    ./networking.nix

    ./forgejo.nix
    ./mailserver.nix
    ./postgresql.nix
  ];

  networking.hostName = "webforge";
  networking.domain = "tahoe-lafs.org";

  system.stateVersion = "23.11";
}
