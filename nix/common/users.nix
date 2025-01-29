# This should be applied on all hosts
{ config, pkgs, ... }: {
  # always use only the configured users
  users.mutableUsers = false;
  users.users = {
    root = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIZtWY7t8HVnaz6bluYsrAlzZC3MZtb8g0nO5L5fCQKR benoit@leastauthority.com"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJlPneIaRT/mqu13N83ctEftub4O6zAfi6qgzZKerU5o florian@leastauthority.com"
      ];
    };
    # Configure the bot user for continuous deployment
    bot-cd = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
      ];
      packages = [
        pkgs.git
      ];
      # Authorize the supplied key to run the deployment update command.
      openssh.authorizedKeys.keys = [
        ''
          restrict,command="sudo ${../update-deployment} ${config.system.name}" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDH2xh00bSuKagJWebx21N6rLaRExk97rk9f79/jA4XN bot-cd@tahoe-lafs.org
        ''
      ];
    };
  };
  security.sudo.wheelNeedsPassword = false;
}
