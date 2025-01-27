{ pkgs, config, lib, ... }: {

  users.users = {
    bot-www = {
      description = "Bot user to deploy websites";
      isNormalUser = true;
      group = "nginx";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0d6K/8HZjOQEUViQ363sYJFHdTCp22SW5DPyykSHtb bot-www@tahoe-lafs.org"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/www 0775 nginx nginx"
  ];

  services.nginx = {
    enable = true;
    virtualHosts = {
      # Define a live site generated from the main branch - https://forge.tahoe-lafs.org/tahoe-lafs/web-landing-page
      "home.tahoe-lafs.org" = {
        enableACME = true;
        forceSSL = true;
        root = "/var/www/site";
        locations = {
          "/" = {
            extraConfig = ''
              rewrite trac/tahoe-lafs/ticket/(.*)$ https://forge.tahoe-lafs.org/tahoe-lafs/trac/issues/$1 redirect;
              rewrite trac/tahoe-lafs/wiki/(.*)$ https://forge.tahoe-lafs.org/tahoe-lafs/trac/wiki/$1 redirect;
              rewrite ((~|downloads|hacktahoelafs|pipermail|trac).*)$ https://legacy.tahoe-lafs.org/$1 redirect;
            '';
          };
        };
      };
      # Define a preview site generated per pull-request - https://force.tahoe-lafs.org/tahoe-lafs/web-landing-page
      "preview.tahoe-lafs.org" = {
        enableACME = true;
        forceSSL = true;
        root = "/var/www/preview";
        locations = {
          "/" = {
            extraConfig = ''
              rewrite trac/tahoe-lafs/ticket/(.*)$ https://forge.tahoe-lafs.org/tahoe-lafs/trac/issues/$1 redirect;
              rewrite trac/tahoe-lafs/wiki/(.*)$ https://forge.tahoe-lafs.org/tahoe-lafs/trac/wiki/$1 redirect;
              rewrite ((~|downloads|hacktahoelafs|pipermail|trac).*)$ https://legacy.tahoe-lafs.org/$1 redirect;
            '';
          };
        };
      };
      # Let's proxy the legacy site under a new hostname to serve the above redirections
      "legacy.tahoe-lafs.org" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            # We could use a new hostname and then verify the certificate,
            # but we need (root access) to change the legacy configuration
            proxyPass = "https://74.207.252.227/";
            extraConfig = ''
              proxy_ssl_verify off;
              rewrite trac/tahoe-lafs/wiki/WikiStart$ https://forge.tahoe-lafs.org/tahoe-lafs/trac/wiki/Home redirect;
              rewrite trac/tahoe-lafs/wiki/ViewTickets$ https://forge.tahoe-lafs.org/tahoe-lafs/trac/issues redirect;
              rewrite trac/tahoe-lafs/wiki/(.*)\?action=history$ https://forge.tahoe-lafs.org/tahoe-lafs/trac/wiki/$1?action=_revision redirect;
              rewrite trac/tahoe-lafs/wiki/(.*)$ https://forge.tahoe-lafs.org/tahoe-lafs/trac/wiki/$1 redirect;
              rewrite trac/tahoe-lafs/ticket/(.*)$ https://forge.tahoe-lafs.org/tahoe-lafs/trac/issues/$1 redirect;
              rewrite trac/tahoe-lafs/newticket$ https://forge.tahoe-lafs.org/tahoe-lafs/trac/issues/new redirect;
              rewrite trac/tahoe-lafs/timeline$ https://forge.tahoe-lafs.org/tahoe-lafs/trac/activity;
              rewrite trac/tahoe-lafs/roadmap$ https://forge.tahoe-lafs.org/tahoe-lafs/trac/milestones;
              rewrite trac/tahoe-lafs/browser/git/(.*)$ https://forge.tahoe-lafs.org/tahoe-lafs/tahoe-lafs/src/branch/master/$1 redirect;
              rewrite trac/tahoe-lafs/browser/trunk/(.*)$ https://forge.tahoe-lafs.org/tahoe-lafs/tahoe-lafs/src/branch/master/$1 redirect;
              rewrite trac/tahoe-lafs/browser/?$ https://forge.tahoe-lafs.org/tahoe-lafs/tahoe-lafs redirect;
            '';
          };
        };
      };
    };
  };
}
