# This file is where we define all our users and their attributes (e.g.: email, keys, ...),
# so those can be re-used with different providers (e.g.: aws, hcloud, gandi, ...)
locals {
  users = {
    benoit = {
      email = "benoit@leastauthority.com",
      ssh_keys = [
        {
          id  = "000619776016", # could be anything, but unique per user
          key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIZtWY7t8HVnaz6bluYsrAlzZC3MZtb8g0nO5L5fCQKR benoit@leastauthority.com",
        },
      ],
    },
    florian = {
      email = "florian@leastauthority.com",
      ssh_keys = [
        {
          id  = "000018054987", # could be anything, but unique per user
          key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJlPneIaRT/mqu13N83ctEftub4O6zAfi6qgzZKerU5o florian@leastauthority.com",
        },
      ],
    },
  }

  # In many cases, the ssh keys from all the users above will be authorized to access some ressources
  # (e.g.: a new server). So we better collect all the ssh keys together in a local variable,
  # and give them a unique name (e.g.: one username with multiple keys)
  # 
  ssh_keys = flatten([
    for username, values in local.users : [
      for v in values.ssh_keys : {
        name       = format("%s-%s", username, v.id)
        public_key = v.key
      }
    ]
  ])
}

# Now we have all the ssh keys of all our users, we can deploy and manage them
# so Hetzner can use to provision our resources (e.g.: new VPS)
resource "hcloud_ssh_key" "ssh_keys" {
  for_each = {
    for key in local.ssh_keys : "tf-${key.name}" => key.public_key
  }

  name       = each.key
  public_key = each.value
}
