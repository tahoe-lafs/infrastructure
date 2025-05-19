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

    # Configure the virtualhosts to serve the pages
    virtualHosts = {
      # Define a live site to serve the content generated from the main branch
      # See https://github.com/tahoe-lafs/web-landing-page
      "home.of.tahoe-lafs.org" = {
        enableACME = true;
        forceSSL = true;
        root = "/var/www/live";
        # serverAliases = [
        #   "www.tahoe-lafs.org"
        #   "tahoe-lafs.org"
        # ];
        extraConfig = ''
          # Redirect to the main domain
          if ($http_host != home.of.tahoe-lafs.org) {
            rewrite ^(.*)$ https://home.of.tahoe-lafs.org$1 redirect;
          }
          # Redirect unmigrated pages to the legacy site:
          # - all trac projects - tahoe-lafs is pending for Forgejo, others are mostly stalled
          # - downloads - still used to publish new releases
          # - pipermail - still serving some mailing archive (not older than 02-Dec-2021) before lists.tahoe-lafs.org
          # - hacktahoelafs - to be migrated as a simple blog post or a special page
          # - user home dirs (e.g. ~trac, ~warner and ~zooko) - still holds files referred from some other places
          rewrite (trac|downloads|pipermail|hacktahoelafs|~[^/]+)(|/.*)$ https://legacy.of.tahoe-lafs.org/$1$2 redirect;
        '';
      };

      # Define a preview site to serve the content generated from per pull-requests
      # See https://github.com/tahoe-lafs/web-landing-page/pulls
      "preview.of.tahoe-lafs.org" = {
        enableACME = true;
        forceSSL = true;
        root = "/var/www/preview";
      };

      # Proxy the legacy site under a separate hostname to allow (read) access if needed
      "legacy.of.tahoe-lafs.org" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          # Proxy all requests to legacy linode server
          "/" = {
            proxyPass = "https://74.207.252.227/";
          };
        };
      };
    };
  };
}
