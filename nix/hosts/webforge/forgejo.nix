{ pkgs, config, lib, ... }: {

  sops = {
    secrets = {
      forgejo-mailer-pass = {
        owner = config.services.forgejo.user;
        group = config.services.forgejo.group;
        key = "smtp-noreply-pass";
        sopsFile = ../../../secrets/common.yaml;
      };
    };
  };

  services.nginx = {
    virtualHosts = {
      # Forgejo site
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
      mailer = {
        # Forgio needs to be able to send emails for registration and password reset
        # And sendmail does not work - https://github.com/NixOS/nixpkgs/issues/103446
        # not even with systemd.services.gitea.serviceConfig.RestrictAddressFamilies = [ "AF_NETLINK" ];
        # So the mailer have to use smtp until this gets fixed upstream 
        ENABLED = true;
        PROTOCOL = "smtps";
        SMTP_ADDR = "mail.87b59b92.nip.io";
        SMTP_PORT = 465;
        FROM = "noreply@forge.87b59b92.nip.io";
        USER = "noreply@87b59b92.nip.io";
      };
      migrations = {
        ALLOWED_DOMAINS = "*.latfa.net, github.com, *.github.com, gitlab.com, *.gitlab.com, codeberg.org, *.codeberg.org, *.forgejo.org";
      };
      oauth2_client = {
        #ACCOUNT_LINKING = "login";        # default: no automatic linking based on username or email
        #ENABLE_AUTO_REGISTRATION = false; # default: user need to choose to register or link
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
    secrets = {
      # security = {
      #   INTERNAL_TOKEN = config.sops.secrets.forgejo-internal-token.path;
      #   SECRET_KEY = config.sops.secrets.forgejo-secret-key.path;
      # };
      mailer = {
        PASSWD = config.sops.secrets.forgejo-mailer-pass.path;
      };
    };
  };
}
