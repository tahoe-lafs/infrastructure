{ pkgs, config, lib, ... }: {

  sops = {
    secrets = {
      forgejo-internal-token = {
        owner = config.services.forgejo.user;
        group = config.services.forgejo.group;
        mode = "0440";
      };
      forgejo-secret-key = {
        owner = config.services.forgejo.user;
        group = config.services.forgejo.group;
        mode = "0440";
      };
      forgejo-mailer-pass = {
        owner = config.services.forgejo.user;
        group = config.services.forgejo.group;
        key = "smtp-noreply-pass";
        sopsFile = ../../../secrets/common.yaml;
      };
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      # Forgejo site
      "forge.tahoe-lafs.org" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            proxyPass = "http://localhost:3000";
            extraConfig = ''
              client_max_body_size 512M;
              proxy_set_header Connection $http_connection;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
        };
      };
    };
  };

  services.forgejo = {
    enable = true;
    settings = {
      actions = {
        ENABLED = true;
      };
      api = {
        MAX_RESPONSE_ITEMS = 250;
      };
      indexer = {
        ISSUE_INDEXER_TYPE = "db";
      };
      mailer = {
        # This we need to change,
        # but it will require some work 
        ENABLED = true;
        PROTOCOL = "smtps";
        SMTP_ADDR = "mail.tahoe-lafs.org";
        SMTP_PORT = 465;
        FROM = "noreply@webforge.tahoe-lafs.org";
        USER = "noreply@tahoe-lafs.org";
        PASSWD = "/run/secrets/forgejo-mailer-pass";
      };
      migrations = {
        ALLOWED_DOMAINS = "*.latfa.net, github.com, *.github.com, gitlab.com, *.gitlab.com, codeberg.org, *.codeberg.org, *.forgejo.org";
      };
      oauth2_client = {
        #ACCOUNT_LINKING = "login";        # default: no automatic linking based on username or email
        #ENABLE_AUTO_REGISTRATION = false; # default: user need to choose to register or link
        UPDATE_AVATAR = true;
      };
      security = {
        INTERNAL_TOKEN = lib.mkForce "";
        INTERNAL_TOKEN_URI = "file:${config.sops.secrets.forgejo-internal-token.path}";
        SECRET_KEY = lib.mkForce "";
        SECRET_KEY_URI = "file:${config.sops.secrets.forgejo-secret-key.path}";
      };
      server = {
        HTTP_PORT = 3000;
        ROOT_URL = "https://forge.tahoe-lafs.org/";
      };
      service = {
        REGISTER_EMAIL_CONFIRM = true;
        ENABLE_CAPTCHA = true;
        CAPTCHA_TYPE = "image";
      };
    };
  };
}
