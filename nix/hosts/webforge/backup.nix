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
      "backup	" + config.services.postfix.config.queue_directory + "	postfix_queue/\n" +
      "backup	" + "/var/www" + "	www_sites/\n" +
      "backup	" + config.services.forgejo.stateDir + "	forgejo_data/\n" +
      "backup_script	" + ./backup_pgsql.sh + "	postgres/\n";
  };

  # Off-site backups
  sops.secrets."backup/encryptionPassword" = {};
  sops.secrets."backup/sshKey" = {};

  services.borgbackup.jobs.rsnapshot = {
    paths = "/var/rsnapshot/daily.0";
    repo = "x6p4a1ph@x6p4a1ph.repo.borgbase.com:repo";
    startAt = [ ]; # Triggered by rsnapshot cmd_postexec
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat \"${config.sops.secrets."backup/encryptionPassword".path}\"";
    };
    environment = {
      BORG_RSH = "ssh -i \"${config.sops.secrets."backup/sshKey".path}\" -o StrictHostKeyChecking=accept-new";
    };
  };
}
