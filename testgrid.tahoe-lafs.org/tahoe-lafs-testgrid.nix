# Define a NixOS module that sets up the Tahoe-LAFS test grid.
{ config, ... }: {
  # Configure Tahoe to run here.
  services.tahoe = {
    # Run two introducers so folks can play around with the multi-introducer
    # support if they want.
    introducers = {
      # Just have them listen on different ports.
      alpha.tub.port = 5000;
      beta.tub.port = 5001;
    };

    # Run three storage nodes.  They all share available storage space on this
    # system but having more than one makes it more interesting to run a
    # client.  On a more realistic deployment these would all be run
    # separately from other to make their failure modes as independent as
    # possible.
    nodes = {
      alpha = {
        web.port = null;
        storage.enable = true;
        tub.port = 5002;
      };
      beta = {
        web.port = null;
        storage.enable = true;
        tub.port = 5003;
      };
      gamma = {
        web.port = null;
        storage.enable = true;
        tub.port = 5004;
      };
    };
  };

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
