# This should be applied on all hosts
{ config, lib, pkgs, modules, sources, ... }: {
  imports = [
    # Set options intended for a "small" NixOS: Do not build X and docs.
    <nixpkgs/nixos/modules/profiles/minimal.nix>

    ./users.nix
    ./sops.nix
  ];

  services.journald.extraConfig = ''
    SystemMaxUse=500M
  '';

  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    randomizedDelaySec = "45min";
    options = lib.mkDefault "--delete-older-than 14d";
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

  # NixOS likes to fill up boot partitions with (by default) 100 old kernels.
  # Keep a (for us) more reasonable number around.
  boot.loader.grub.configurationLimit = 3;

  environment.systemPackages = with pkgs; [
    # FIXME: ssh-to-gpg is broken since 1.1.3 in NixOS 24.11
    # https://github.com/Mic92/ssh-to-pgp/issues/73
    pkgs.oldstable.ssh-to-pgp
    vim
  ];
}
