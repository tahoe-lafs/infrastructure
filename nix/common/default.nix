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
    gitMinimal
    ssh-to-pgp
    vim
  ];

  # Silent cron email - connection is refused anyway
  services.cron.mailto = "";

  nix.extraOptions = "experimental-features = nix-command flakes";
}
