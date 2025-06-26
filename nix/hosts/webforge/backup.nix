{ pkgs, config, lib, ... }: {

  # Local backups
  services.rsnapshot = {
    enable = true;
    cronIntervals = {
      daily = "55 5 * * *";
    };
    # Keep 7 daily + 4 weekly + 3 monthly = max 14 local backups.
    # Note: Fields are separated by tabs, not spaces.
    extraConfig = ''
      snapshot_root	/var/rsnapshot/
      retain	daily	7
      retain	weekly	4
      retain	monthly	3
      '' +
      "cmd_preexec	" + ./backup_preexec.sh + "\n" +
      "cmd_postexec	" + ./backup_postexec.sh + "\n" +
      "backup	" + config.mailserver.dkimKeyDirectory + "	opendkim_keys/\n" +
      "backup	" + "/var/lib/postfix/queue" + "	postfix_queue/\n" +
      "backup	" + "/srv/www" + "	www_sites/\n" +
      "backup	" + config.services.forgejo.stateDir + "	forgejo_data/\n" +
      "backup_script	" + ./backup_pgsql.sh + "	postgres/\n";
  };

  # TODO: Off-site backups
  # services.borgbackup.jobs.rsnapshot = {
  # };
}
