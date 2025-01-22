# Tahoe-LAFS Infrastructure

The software that defines the Tahoe-LAFS project's infrastructure.

## Abstract

This repository was initially created in Sep 2022 as an effort to deploy and
manage a `testgrid` server using NixOS (now retired).

Since January 2025, some members of the community are seeking to re-use this repository
to deploy and manage some new [systems](#managed-systems).

In addition to the [Nix](https://nixos.org/) code covering the software installed on those servers,
an [OpenToFu](https://opentofu.org/) plan should handle the definition of the related infrastructure (e.g.: VMs and DNS records).

**Warning**: The content of this repository is currently a work in progress. See the [Roadmap](docs/Roadmap.md) for more information.

## How to Contribute

- Read the doc and the code, consult the existing issues and visit https://tahoe-lafs.org/ to get in touch with the community
- Describe the bug/problem or the missing info/feature in a new issue in this repository
- Submit pull requests (preferably one per issue) and verify the check status

  **Caveat**: because they need access to the repository secrets, changes related to OpenToFu will only be triggered on local branches (which means a maintainer will have to be involved - see [Roadmap](docs/Roadmap.md)). Changes related to Nix may not suffer the same restriction.

- Once a pull request as been approved and merged, verify the expected changes and provide feedback in the issue(s) if needed

## Managed Systems

Here is a short description of the systems managed from this repository.

### Testgrid

Initially deployed re-using the NixOS configuration written in 2022, this server is a Tahoe-LAFS stand-alone grid allowing contributors to test any client software (e.g.: mobile apps).

**Warning**: This server should be re-configured on regular basis,
which means the availability of the related services and their data will NOT be guaranteed very long.

More info:

- [README](./testgrid.tahoe-lafs.org/README) file
- [TestGrid](https://tahoe-lafs.org/trac/tahoe-lafs/wiki/TestGrid) wiki page

### Webforge

Tahoe-LAFS issue tracking, wiki and web server meant to replace the current [Trac](https://tahoe-lafs.org/trac/tahoe-lafs) server.

**Notice**: This server could be managed only for a limited period of time,
depending if/when the community wants to migrate the content elsewhere (e.g.: Codeberg).

More info:

- [MoveOffTrac](https://github.com/tahoe-lafs/MoveOffTrac) repository
- [MoveOffTrac](https://tahoe-lafs.org/trac/tahoe-lafs/wiki/MoveOffTrac) wiki page

## Deployment Workflow

This section describes how the resources defined in this repository should be deployed.

### Underlying Infrastructure

1. Ensure the relevant ssh public keys are defined in the relevant Hetzner project (e.g.: Tahoe-LAFS)
2. Create a new Debian VPS referring to at least one ssh key in the same project
3. Infect the VPS with NixOS (e.g.: using `cloud-init`)
4. Publish the new A/AAAA/PTR/CNAME DNS records the related zone (e.g.: `tahoe-lafs.org` hosted by Gandi)

### OS and Software

###  Provisioning

This section describes how to proceed for the first deployment of a NixOS server.

The NixOS configuration has to be manually deployed at least once using:

```
nixos-rebuild switch --target-host the-remote-host-to-deploy
```

This first deployment should bootstrap (or fix) the requirements for the automation of the next ones:

1. Retrieve the the public ssh key of the server deployed earlier and
   add/update the ssh `known_hosts` files (in this repository and locally)
2. Convert this public ssh key in a gpg one to encrypt the secrets with sops,
   so the server it-self will be able to decrypt the secrets it needs.

### Continuous Deployment

Subsequent deployment should be triggered by GHA when merging a PR into the main branch.

#### Underlying Infrastructure

Assuming OpenToFu is used, any changes to the existing plan should be automatically verified and
described in a comment added on the pull request.

Most failures should be detailed with the relevant error messages also published in this comment.

#### OS and Software

Assuming this repository has been configured with:

- a secret ssh (private) key to interact with the OS already [provisioned](#provisioning),
- some (public) deployment (ssh) keys allowing each [provisioned](#provisioning) servers to checkout the Nix code,

a pull request would automatically run `nix flake check` which should trigger the `nix build` of
all the `nixosConfiguration` and their dependencies (could take a while).

And here is how the automated deployment should work once a pull request is merged:

1. the GHA runner initiate an remote shell via ssh using the private ssh key,
2. the authenticated user triggers an hardened deployment script (the only command available to him),
3. this script checks out the Nix code from the repository at the targeted revision and
4. call the `nixos-rebuild` to **`switch`** to the `nixosConfiguration` on the local host.

The output of the deployment script should be visible in the GHA logs.
