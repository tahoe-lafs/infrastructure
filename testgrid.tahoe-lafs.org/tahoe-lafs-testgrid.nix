# Define a NixOS module that sets up the Tahoe-LAFS test grid.
{ config, pkgs, ... }:
let
  # Use upstream packaging.  The NixOS 21.05 package is broken (though
  # master should already have a fix for that).  However, maybe we want to
  # run bleeding edge on this deployment anyway.
  package = pkgs.callPackage ./tahoe-lafs.nix { };
in {
  # Configure Tahoe to run here.
  services.tahoe = {

    # Run two introducers so folks can play around with the multi-introducer
    # support if they want.
    introducers = {
      # Just have them listen on different ports.
      alpha = {
        inherit package;
        nickname = "alpha-introducer";
        tub.port = 5000;
      };
      beta = {
        inherit package;
        nickname = "beta-introducer";
        tub.port = 5001;
      };
    };

    # Run three storage nodes.  They all share available storage space on this
    # system but having more than one makes it more interesting to run a
    # client.  On a more realistic deployment these would all be run
    # separately from other to make their failure modes as independent as
    # possible.
    nodes =
    let
      # XXX NixOS module doesn't support multi-introducer configuration.
      introducer = "pb://fodk4doc64febdoxke3a4ddfyanz7ajd@tcp:157.90.125.177:5000/el4fo3rm2h22cnilukmjqzyopdgqxrd2";
    in {
      alpha = {
        inherit package;
        nickname = "alpha-storage";
        # XXX NixOS module requires we configure a web port even if we don't
        # want one.
        web.port = 2002;
        storage.enable = true;
        tub.location = config.networking.fqdn;
        tub.port = 5002;
        client.introducer = introducer;
      };
      beta = {
        inherit package;
        nickname = "beta-storage";
        # XXX
        web.port = 2003;
        storage.enable = true;
        tub.location = config.networking.fqdn;
        tub.port = 5003;
        client.introducer = introducer;
      };
      gamma = {
        inherit package;
        nickname = "gamma-storage";
        # XXX
        web.port = 2004;
        storage.enable = true;
        tub.location = config.networking.fqdn;
        tub.port = 5004;
        client.introducer = introducer;
      };
    };
  };

  # XXX The NixOS Tahoe service doesn't set these and NixOS gets angry.
  users.users."tahoe.alpha".group = "tahoe.alpha";
  users.groups."tahoe.alpha" = {};

  users.users."tahoe.beta".group = "tahoe.beta";
  users.groups."tahoe.beta" = {};

  users.users."tahoe.gamma".group = "tahoe.gamma";
  users.groups."tahoe.gamma" = {};

  users.users."tahoe.introducer-alpha".group = "tahoe.introducer-alpha";
  users.groups."tahoe.introducer-alpha" = {};

  users.users."tahoe.introducer-beta".group = "tahoe.introducer-beta";
  users.groups."tahoe.introducer-beta" = {};

  networking.firewall.allowedTCPPorts = with config.services.tahoe; [
    # Let traffic through to the introducers
    introducers.alpha.tub.port
    introducers.beta.tub.port

    # ... and storage servers.
    nodes.alpha.tub.port
    nodes.beta.tub.port
    nodes.gamma.tub.port
  ];
}
