# This should be applied on all hosts
{ config, lib, pkgs, modules, sources, nixpkgs, ... }: {
  imports = [
    # Set options intended for a "small" NixOS: Do not build X and docs.
    (nixpkgs + "/nixos/modules/profiles/minimal.nix")

    ./users.nix
    ./sops.nix
  ];

  # Keep log file disk usage in check.
  # The default is 10% of the partitition size or so.
  services.journald.extraConfig = ''
    # One week of logs ought to be enough
    MaxRetentionSec=1week
    MaxFileSec=1day
    SystemMaxUse=250M
  '';

  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    randomizedDelaySec = "45min";
    options = lib.mkDefault "--delete-older-than 14d";
  };

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  # Be a good internet citizen
  networking.firewall = {
    enable = true;
    allowPing = true;
    rejectPackets = true;
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
    # FIXME: ssh-to-gpg is broken in 1.1.3 and 1.1.4 in NixOS 24.11
    # https://github.com/Mic92/ssh-to-pgp/issues/73
    # But we can have the fix in >= 1.1.5 from unstable until NixOS 25.05
    pkgs.unstable.ssh-to-pgp
    vim
  ];
}
