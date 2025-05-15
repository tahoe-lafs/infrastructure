{ config, ... }: {

  services.postgresql = {
    ensureDatabases = [
      config.services.forgejo.database.name
    ];
    ensureUsers = [
      {
        name = config.services.forgejo.database.user;
        ensureDBOwnership = true;
      }
    ];
  };
}
