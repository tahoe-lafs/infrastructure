{ ... }: {
  # Initial empty root password for easy login:
  users.users.root.initialHashedPassword = "";
  services.openssh.settings.PermitRootLogin = "prohibit-password";

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    # If you want access to administer the system, add your ssh pubkey to this
    # list.  Once the updated configuration is deployed, your key will be
    # accepted for root authentication.
    #
    # A good change would be to create actual user accounts with sudo
    # configuration instead, probably.
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHx7wJQNqKn8jOC4AxySRL2UxidNp7uIK9ad3pMb1ifF flo@vantaa"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIZtWY7t8HVnaz6bluYsrAlzZC3MZtb8g0nO5L5fCQKR benoit@leastauthority.com"
  ];
}
