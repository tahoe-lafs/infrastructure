{ pkgs, ... }: {

  # User to deploy the pages generated elsewhere
  users.users = {
    bot-www = {
      description = "Bot user to deploy web pages";
      isNormalUser = true;
      group = "nginx";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0d6K/8HZjOQEUViQ363sYJFHdTCp22SW5DPyykSHtb bot-www@tahoe-lafs.org"
      ];
      packages = [
        pkgs.rsync
      ];
    };
  };

  # Ensure there is a directory to deploy the pages
  systemd.tmpfiles.rules = [
    "d /var/www 0775 nginx nginx"
    "d /var/www/live 0775 bot-www nginx"
    "d /var/www/preview 0775 bot-www nginx"
  ];

  services.nginx = {
    # The service and the firewall should already be configured elsewhere - see configuration.nix
    # But we need to enable it here (again) to evaluate the `nginx` group in the lines above.
    enable = true;
    # Configure a cache to speedup the replies proxied from the legacy site
    proxyCachePath.legacy = {
      enable = true;
      keysZoneName = "legacy";
      maxSize = "128m";
    };

    # Configure the virtualhosts to serve the pages
    # TODO: Replace 87b59b92.nip.io by tahoe-lafs.org below when ready - trac#4162
    virtualHosts = {
      # Define a live site to serve the content generated from the main branch
      # See https://github.com/tahoe-lafs/web-landing-page
      "live.www.87b59b92.nip.io" = {
        enableACME = true;
        forceSSL = true;
        root = "/var/www/live";
        serverAliases = [
          "www.87b59b92.nip.io"
          "87b59b92.nip.io"
        ];
        extraConfig = ''
          # Redirect to the main domain
          if ($http_host != 87b59b92.nip.io) {
            rewrite ^(.*)$ https://87b59b92.nip.io$1 redirect;
          }
          # Redirect unmigrated pages to the legacy site:
          # - all trac projects - tahoe-lafs is pending for Forgejo, others are mostly stalled
          # - downloads - still used to publish new releases
          # - pipermail - still serving some mailing archive (not older than 02-Dec-2021) before lists.tahoe-lafs.org
          # - hacktahoelafs - to be migrated as a simple blog post or a special page
          # - user home dirs (e.g. ~trac, ~warner and ~zooko) - still holds files referred from some other places
          rewrite (trac|downloads|pipermail|hacktahoelafs|~[^/]+)(|/.*)$ https://legacy.87b59b92.nip.io/$1$2 redirect;
        '';
      };

      # Define a preview site to serve the content generated from per pull-requests
      # See https://github.com/tahoe-lafs/web-landing-page/pulls
      "preview.www.87b59b92.nip.io" = {
        enableACME = true;
        forceSSL = true;
        root = "/var/www/preview";
      };

      # Proxy the legacy site under a separate hostname to allow (read) access if needed
      "legacy.87b59b92.nip.io" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          # Proxy all requests to legacy linode server
          # and cache replies to save some time and BW
          "/" = {
            proxyPass = "https://74.207.252.227/";
            extraConfig = ''
              proxy_cache legacy;
            '';
          };
        };
      };
    };
  };
}
