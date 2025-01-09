# Do not modify this file!  It was generated by ‘nixos-generate-config’.
# Please make changes to configuration.nix or one of the modules it references
# instead.
#
# Despite being a generated file, this is still checked in to our repository.
# This makes it possible to evaluate the top-level ``configuration.nix`` on
# developer systems which is sometimes useful.  If the deployment hardware
# changes it might be necessary to generate a new version of this file on the
# system and then check it in.  Since the deployment hardware is really a VM
# this isn't too likely to happen (more likely is that we'll provision a new
# VM and need a new hardware configuration for it - unless it happens to be
# configured just like this one, which it might be).

{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
}
