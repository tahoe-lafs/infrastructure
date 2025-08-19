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
        # And sendmail does not work - https://github.com/NixOS/nixpkgs/issues/103446
        # not even with systemd.services.gitea.serviceConfig.RestrictAddressFamilies = [ "AF_NETLINK" ];
        # So the mailer have to use smtp until this gets fixed upstream
        ENABLED = true;
        PROTOCOL = "smtp";
        SMTP_ADDR = "localhost";
        SMTP_PORT = 25;
        FROM = "noreply@forge.of.tahoe-lafs.org";
      };
      migrations = {
        ALLOWED_DOMAINS = "*.latfa.net, github.com, *.github.com, gitlab.com, *.gitlab.com, codeberg.org, *.codeberg.org, *.forgejo.org";
      };
      oauth2_client = {
        # ACCOUNT_LINKING = "login";        # no automatic linking based on username or email (by default)
        # ENABLE_AUTO_REGISTRATION = false; # force user to choose to register or link account (by default)
        REGISTER_EMAIL_CONFIRM = false;     # override the service setting to avoid confirmation when registering via oauth2
        UPDATE_AVATAR = true;               # update avatar if available from the OAuth2 provider
      };
      server = {
        HTTP_PORT = 3000;
        ROOT_URL = "https://forge.of.tahoe-lafs.org/";
      };
      service = {
        DISABLE_REGISTRATION = true;     # only admin can register until the migration is completed
        # REGISTER_EMAIL_CONFIRM = true; # when not registering via oauth2
        # ENABLE_CAPTCHA = true;         # to reduce spam registration
        # CAPTCHA_TYPE = "image";
      };
    };
  };
}
