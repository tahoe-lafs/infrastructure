# Roadmap

At the time of writing, this repository does not provide a working solution to manage the systems as described.

Here follows a list of early steps to reach this goal.
Some of them should become issues or pull requests.

At the end the whole section might be replaced by long term goals.

For [Testgrid](../README.md#testgrid):

- [X] Fix and rework the Nix code to deploy the current Tahoe-LAFS software (#6)
- [ ] Implement or adapt the OpenToFu plan to cover the `testgrid` and
  import the resource already deployed (on Hetzner and Gandi if possible)
- [ ] Refactor the Nix code to integrate the `nixosConfiguration` with the top-level flake,
  which will be used to manage and automated the deployment of all NixOS configurations

For [Webforge](../README.md#webforge):

- [X] Implement the OpenToFu plan for Hetzner and its CI/CD workflow with GHA
- [X] Implement the NixOS configuration and its CI/CD workflow with GHA

For the [Deployment Workflow](../README.md#deployment-workflow):

- [ ] Automated the DNS configuration using OpenToFu and the relevant credentials from Gandi
  (see [#4162](https://tahoe-lafs.org/trac/tahoe-lafs/ticket/4162))
- [ ] Describe the [provisioning](../README.md#provisioning) steps with the relevant paths and snippets
- [ ] Investigate how to allow pull request from (external) fork (with read-only token?)
