# The API token to interact with Hetzner Cloud
variable "hcloud_token" {
  type      = string
  sensitive = true
}
# The API token to interact with deSec DNS
variable "desec_token" {
  type      = string
  sensitive = true
}

