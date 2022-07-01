# Define a NixOS module that sets up the Tahoe-LAFS test grid.
{ system, config, pkgs, tahoe-lafs, ... }:
let
  package = tahoe-lafs.packages.${system}.tahoe-lafs-python39;
in {
  # Configure Tahoe to run here.
  services.tahoe = {

    # Run two introducers so folks can play around with the multi-introducer
    # support if they want.
    introducers = {
      # Just have them listen on different ports.
      alpha = {
        inherit package;
        settings.node = {
          nickname = "alpha-introducer";
          "tub.port" = 5000;
        };
      };
      beta = {
        inherit package;
        settings.node = {
          nickname = "beta-introducer";
          "tub.port" = 5001;
        };
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
        settings = {
          node = {
            nickname = "alpha-storage";
            "tub.location" = "${config.networking.fqdn}:5002";
            "tub.port" = 5002;
          };
          storage.enabled = true;
          client."introducer.furl" = introducer;
        };
      };
      beta = {
        inherit package;
        settings = {
          node = {
            nickname = "beta-storage";
            "tub.location" = "${config.networking.fqdn}:5003";
            "tub.port" = 5003;
          };
          storage.enabled = true;
          client."introducer.furl" = introducer;
        };
      };
      gamma = {
        inherit package;
        settings = {
          node = {
            nickname = "gamma-storage";
            "tub.location" = "${config.networking.fqdn}:5004";
            "tub.port" = 5004;
          };
          storage.enabled = true;
          client.introducer = introducer;
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = with config.services.tahoe; [
    # Let traffic through to the introducers
    introducers.alpha.settings.node."tub.port"
    introducers.beta.settings.node."tub.port"

    # ... and storage servers.
    nodes.alpha.settings.node."tub.port"
    nodes.beta.settings.node."tub.port"
    nodes.gamma.settings.node."tub.port"
  ];
}
