{ ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # This was generated while setting up the machine with nixos-infect.
    ./networking.nix

    # Run a Tahoe-LAFS grid
    ./tahoe-lafs-testgrid.nix
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
