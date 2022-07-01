{ tahoe-lafs-module, ... }: {

  imports = [
    # Get the version of the module we prefer, the one provided by the
    # Tahoe-LAFS flake.
    tahoe-lafs-module
  ];
}
