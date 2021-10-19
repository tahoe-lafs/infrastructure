{ callPackage }:
let
  #
  # You can switch to a different revision of tahoe-lafs by running:
  #
  #   nix-prefetch-github --nix --rev <rev> tahoe-lafs tahoe-lafs > /path/to/repo-tahoe-lafs-master.nix
  #
  # An interesting ``<rev>`` to use is sometimes ``$(git rev-parse HEAD)`` if
  # your working directory is a checkout of tahoe-lafs.
  #
  repo = import ./repo-tahoe-lafs-master.nix;
  tahoe-lafs = callPackage "${repo}/nix/py3.nix" { };
in
  tahoe-lafs
