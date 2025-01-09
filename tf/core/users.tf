# This file only list our user's email and public keys,
# so those can be re-used elsewhere (e.g.: hcloud, gandi, ...)
locals {
  users = {
    benoit = {
      email = "benoit@leastauthority.com",
      ssh_keys = [
        {
          id  = "000619776016",
          key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIZtWY7t8HVnaz6bluYsrAlzZC3MZtb8g0nO5L5fCQKR benoit@leastauthority.com",
        },
      ],
    },
    florian = {
      email = "florian@leastauthority.com",
      ssh_keys = [
        {
          id  = "000018054987",
          key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJlPneIaRT/mqu13N83ctEftub4O6zAfi6qgzZKerU5o florian@leastauthority.com",
        },
      ],
    },
  }

  # Flatten all the ssh keys of each users
  ssh_keys = flatten([
    for username, values in local.users : [
      for v in values.ssh_keys : {
        name       = format("%s-%s", username, v.id)
        public_key = v.key
      }
    ]
  ])
}

# Manage ssh keys
resource "hcloud_ssh_key" "ssh_keys" {
  for_each = {
    for key in local.ssh_keys : "tf-${key.name}" => key.public_key
  }

  name       = each.key
  public_key = each.value
}
