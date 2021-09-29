{ ... }: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # Run a Tahoe-LAFS grid
    ./tahoe-lafs-testgrid.nix

    # Configure authn/authz for system administration
    ./access-control.nix

    # Configure the rest of the system
    ./system-configuration.nix
  ]
}
