# System name: testgrid
# Main FQDN: testgrid.tahoe-lafs.org
# Provider: Hetzner
# OS: NixOS
# Description: Web-based collaborative version control server for Tahoe-LAFS
resource "hcloud_server" "testgrid" {
  name        = "testgrid"
  server_type = "cx22"
  image       = "debian-12"
  location    = "hel1"
  backups     = true
  labels = {
    "env" : "test"
    "source" : "tf-tahoe-lafs-core"
  }
  ssh_keys  = [for k in hcloud_ssh_key.ssh_keys : k.name]
  user_data = <<EOF
#cloud-config

runcmd:
  - curl https://raw.githubusercontent.com/elitak/nixos-infect/5ef3f953d32ab92405b280615718e0b80da2ebe6/nixos-infect | PROVIDER=hetznercloud NIX_CHANNEL=nixos-24.11 bash 2>&1 | tee /tmp/infect.log
EOF
  # Wait for the ssh key(s)
  depends_on = [
    hcloud_ssh_key.ssh_keys
  ]
  lifecycle {
    ignore_changes = [
      # Ignore some post installation changes
      ssh_keys,
      user_data,
    ]
  }
}

# System PTR records
resource "hcloud_rdns" "testgrid_ipv4" {
  server_id  = hcloud_server.testgrid.id
  ip_address = hcloud_server.testgrid.ipv4_address
  dns_ptr    = "testgrid.tahoe-lafs.org"
}

resource "hcloud_rdns" "testgrid_ipv6" {
  server_id  = hcloud_server.testgrid.id
  ip_address = hcloud_server.testgrid.ipv6_address
  dns_ptr    = "testgrid.tahoe-lafs.org"
}
