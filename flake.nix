{
  inputs = {
    # The nixpkgs channels we want to consume
    nixpkgs-24_11.url = "github:NixOS/nixpkgs/nixos-24.11-small";

    # Some links to the above channels for consistent naming in outputs
    nixpkgs.follows = "nixpkgs-24_11";
  };
  outputs = { self, nixpkgs, ... }@attrs: {
    # Generate an attrset of nixosConfigurations based on their system name
    nixosConfigurations = nixpkgs.lib.attrsets.genAttrs [
      "webforge"
    ] (sysname: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;
        modules = [
          { system.name = sysname; }
          ./nix/hosts/${sysname}/configuration.nix
        ];
      }
    );
  };
}
