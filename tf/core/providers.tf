terraform {
  required_version = "~> 1.4"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "= 1.50.1"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}
