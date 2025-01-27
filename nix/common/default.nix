# This should be applied on all hosts
{ config, lib, pkgs, modules, sources, ... }: {
  imports = [
    ./users.nix
    ./sops.nix
  ];

  services.journald.extraConfig = ''
    SystemMaxUse=500M
  '';

  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 30d";
  };

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  networking.firewall = {
    enable = true;
    allowPing = false;
  };

  security.acme = {
    acceptTerms = true;
    # TODO: Decide where else to send notifications from Let's Encrypt
    defaults.email = "it-ops+acme@latfa.net";
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  environment.systemPackages = with pkgs; [
    # FIXME: ssh-to-gpg is broken since 1.1.3 in NixOS 24.11
    # https://github.com/Mic92/ssh-to-pgp/issues/73
    pkgs.oldstable.ssh-to-pgp
    vim
  ];
}
