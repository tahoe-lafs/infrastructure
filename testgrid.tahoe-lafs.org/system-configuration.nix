# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  # Enable flakes.
  # https://nixos.wiki/wiki/Nix_command
  nix.extraOptions = "experimental-features = nix-command flakes";

  # Periodically upgrade NixOS to the latest version.  If enabled, a systemd
  # timer will run `nixos-rebuild switch --upgrade` once a day.
  system.autoUpgrade = {
    enable = true;

    # Reboot the system into the new generation instead of a switch if the new
    # generation uses a different kernel, kernel modules or initrd than the
    # booted system.
    allowReboot = true;
  };

  # NixOS likes to fill up boot partitions with (by default) 100 old kernels.
  # Keep a (for us) more reasonable number around.
  boot.loader.grub.configurationLimit = 3;

  # From https://nixos.wiki/wiki/Storage_optimization
  nix.gc = {
    automatic = true;
    dates = "weekly";
    randomizedDelaySec = "45min";
    options = "--delete-older-than 14d";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
    [
      # Let us check out and update the system configuration repository.
      gitMinimal
    ];

  # Keep log file disk usage in check.
  # The default is 10% of the partitition size or so.
  services.journald.extraConfig = ''
    # One week of logs ought to be enough
    MaxRetentionSec=${toString(7 * (24 * 60 * 60))}s
    MaxFileSec=1day
    SystemMaxUse=250M
  '';

  # Make sure the firewall is enabled.  This is probably the default but let's
  # be explicit and safe.
  networking.firewall.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
