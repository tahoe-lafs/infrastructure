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
  ];

  services.nginx = {
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
          # Only because the original file do not exist uncompressed!
          # And the proxy fails to get the compressed one, unlike a browser?
          # FIXME: (re-)create the missing ~trac/LAFS.svg on the legacy server
          # Or fix the proxy (headers?) to access the compressed file?
          "/~trac/LAFS.svg" = {
            proxyPass = "https://74.207.252.227/~trac/LAFS.svg.gz";
            extraConfig = ''
              proxy_cache       legacy;
              proxy_hide_header Content-Type;
              add_header        Content-Encoding gzip;
              add_header        Content-Type image/svg+xml;
            '';
          };
          # Everything else is proxied but only for GET and HEAD requests
          # This should reduce chances of modification after the migration
          "/" = {
            proxyPass = "https://74.207.252.227/";
            extraConfig = ''
              proxy_cache legacy;
              limit_except GET {
                  deny all;
              }
              # Redirect the legacy links from trac to the landing page for 2nd redirection
              rewrite trac/tahoe-lafs(|/.*)$ https://87b59b92.nip.io/trac/tahoe-lafs$1 redirect;
            '';
          };
        };
      };
    };
  };
}
