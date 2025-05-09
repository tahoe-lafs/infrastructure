{ pkgs, config, ... }: {

  sops = {
    secrets = {
      forgejo-runner-local1-token = {
        # Because the gitea-runner user and group are dynamic,
        # we can not use those in our config!
        # https://github.com/NixOS/nixpkgs/blob/90bd1b26e23760742fdcb6152369919098f05417/nixos/modules/services/continuous-integration/gitea-actions-runner.nix#L211
        # Though, this secret is used only once to register the runner
        mode = "0444";
      };
    };
  };

  # Enable docker to host a local runner
  virtualisation.docker.enable = true;
  # Ensure the local runner can reach this server to register
  # while avoiding localhost:3000 which will not work inside containers
  networking.hosts = {
    "127.0.0.2" = [ "forge.87b59b92.nip.io" ];
  };
  services.gitea-actions-runner = {
    # Use the forgejo fork
    # TODO swtich from unstable to stable with 25.05
    package = pkgs.unstable.forgejo-runner;
    instances = {
      # A local runner which should be carefully registered at org. level,
      # so only users with write/push permissions on org. repos can mess with it
      # TODO: spin a dedicated instance as recommended instead
      "local1" = {
        enable = true;
        url = config.services.forgejo.settings.server.ROOT_URL;
        name = "local1";
        tokenFile = config.sops.secrets.forgejo-runner-local1-token.path;
        labels = [
          # provide a debian base with nodejs for actions
          "lts-bookworm-slim:docker://node:lts-bookworm-slim"
          # provide same image with python
          "lts-bookworm:docker://node:lts-bookworm"
          # provide default images based on catthehacker/ubuntu:act-*
          # wich contain most of the tools needed to run workflows
          "ubuntu-latest:docker://gitea/runner-images:ubuntu-latest"
          "ubuntu-22.04:docker://gitea/runner-images:ubuntu-22.04"
          "ubuntu-20.04:docker://gitea/runner-images:ubuntu-20.04"
        ];
        settings = {
          container = {
            # Mount the socket of the docker host to run docker-in-docker
            options = "--mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock";
            valid_volumes = [
              "/var/run/docker.sock"
            ];
          };
        };
      };
    };
  };
  # Allow rw access from runner to the socket of the docker host
  systemd.services."gitea-runner-local1".serviceConfig.ReadWritePaths="/var/run/docker.sock";
}
