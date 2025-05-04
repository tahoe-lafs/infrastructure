# The API token to interact with Hetzner Cloud
variable "hcloud_token" {
  type      = string
  sensitive = true
}
# The API token to interact with Hetzner DNS
variable "hdns_token" {
  type      = string
  sensitive = true
}

