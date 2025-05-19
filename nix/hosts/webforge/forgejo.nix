{ pkgs, config, lib, ... }: {

  services.nginx = {
    # The service and the firewall should already be configured elsewhere - see configuration.nix
    # Configure the virtualhost for Forgejo
    virtualHosts = {
      "forge.of.tahoe-lafs.org" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            proxyPass = "http://localhost:3000";
            extraConfig = ''
              client_max_body_size 512M;
              proxy_set_header Connection $http_connection;
              proxy_set_header Upgrade $http_upgrade;
            '';
          };
        };
      };
    };
  };

  services.forgejo = {
    enable = true;
    database = {
      type = "postgres";
      user = config.services.forgejo.database.name;
    };
    settings = {
      # Allow maintainers to register runners to this instance
      # This does NOT implement any runners
      # https://forgejo.org/docs/next/admin/actions/
      actions = {
        ENABLED = true;
        DEFAULT_ACTIONS_URL = "https://data.forgejo.org";
      };
      api = {
        MAX_RESPONSE_ITEMS = 250;
      };
      indexer = {
        ISSUE_INDEXER_TYPE = "db";
      };
      mailer = {
        # Forgejo needs to be able to send emails for registration and password reset
        # TODO: choose between local self-hosted and external 3rd party relaying service
        ENABLED = true;
        PROTOCOL = "dummy";
        FROM = "noreply@forge.of.tahoe-lafs.org";
      };
      migrations = {
        ALLOWED_DOMAINS = "*.latfa.net, github.com, *.github.com, gitlab.com, *.gitlab.com, codeberg.org, *.codeberg.org, *.forgejo.org";
      };
      oauth2_client = {
        UPDATE_AVATAR = true;
      };
      server = {
        HTTP_PORT = 3000;
        ROOT_URL = "https://forge.of.tahoe-lafs.org/";
      };
      service = {
        REGISTER_EMAIL_CONFIRM = true;
        ENABLE_CAPTCHA = true;
        CAPTCHA_TYPE = "image";
      };
    };
  };
}
