terraform {
  required_version = "~> 1.4"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "= 1.50.1"
    }
    hetznerdns = {
      source  = "germanbrew/hetznerdns"
      version = "= 3.4.6"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

provider "hetznerdns" {
  api_token = var.hdns_token
}

# Manage ssh authorized keys so Hetzner can use them to provision our resources (e.g.: new VPS)
resource "hcloud_ssh_key" "ssh_keys" {
  for_each = {
    tf-benoit-000619776016 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIZtWY7t8HVnaz6bluYsrAlzZC3MZtb8g0nO5L5fCQKR benoit@leastauthority.com"
  }

  name       = each.key
  public_key = each.value
}
