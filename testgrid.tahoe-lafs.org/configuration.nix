{ ... }: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # This was generated while setting up the machine with nixos-infect.
    ./networking.nix

    # Configure the rest of the system
    ./system-configuration.nix

    # Configure authn/authz for system administration
    ./access-control.nix

    # Run a Tahoe-LAFS grid
    ./tahoe-lafs-testgrid.nix
  ];
}
