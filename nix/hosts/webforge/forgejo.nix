{ pkgs, config, lib, ... }: {

  services.nginx = {
    # The service and the firewall should already be configured elsewhere - see configuration.nix
    # Configure the virtualhost for Forgejo
    virtualHosts = {
      "forge.87b59b92.nip.io" = {
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
      migrations = {
        ALLOWED_DOMAINS = "*.latfa.net, github.com, *.github.com, gitlab.com, *.gitlab.com, codeberg.org, *.codeberg.org, *.forgejo.org";
      };
      oauth2_client = {
        UPDATE_AVATAR = true;
      };
      server = {
        HTTP_PORT = 3000;
        ROOT_URL = "https://forge.87b59b92.nip.io/";
      };
      service = {
        REGISTER_EMAIL_CONFIRM = true;
        ENABLE_CAPTCHA = true;
        CAPTCHA_TYPE = "image";
      };
    };
  };
}
