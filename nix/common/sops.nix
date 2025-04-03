# This should be applied on all hosts
{ config, lib, sops-nix, ... }: {
  imports = [
    sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ../../secrets + "/${config.system.name}.yaml";
    gnupg.sshKeyPaths = [ "/etc/ssh/ssh_host_rsa_key" ];
  };
}
