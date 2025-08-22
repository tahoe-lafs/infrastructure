terraform {
  required_version = "~> 1.4"

  required_providers {
    desec = {
      source  = "valodim/desec"
      version = "0.6.1"
    }
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "= 1.51.0"
    }
  }
}

provider "desec" {
  api_token = var.desec_token
}

provider "hetznerdns" {
  api_token = var.hdns_token
}

# Manage ssh authorized keys so Hetzner can use them to provision our resources (e.g.: new VPS)
resource "hcloud_ssh_key" "ssh_keys" {
  for_each = {
    tf-benoit-000619776016  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIZtWY7t8HVnaz6bluYsrAlzZC3MZtb8g0nO5L5fCQKR benoit@leastauthority.com"
    tf-florian-000018054987 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJlPneIaRT/mqu13N83ctEftub4O6zAfi6qgzZKerU5o florian@leastauthority.com"
  }

  name       = each.key
  public_key = each.value
}
