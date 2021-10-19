{ ... }: {
  # Initial empty root password for easy login:
  users.users.root.initialHashedPassword = "";
  services.openssh.permitRootLogin = "prohibit-password";

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    # Replace this by your SSH pubkey!
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGN4VQm3BIQKEFTw6aPrEwNuShf640N+Py2LOKznFCRT exarkun@bottom"
  ];
}
