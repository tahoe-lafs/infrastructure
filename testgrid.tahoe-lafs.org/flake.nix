{
  inputs.tahoe-lafs.url = "github:tahoe-lafs/tahoe-lafs/flake.nix.2";

  outputs = { self, nixpkgs, tahoe-lafs }: {
    nixosConfigurations.testgrid = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = {
        tahoe-lafs = tahoe-lafs;
        inherit system;
      };
      modules = [
        tahoe-lafs.nixosModules.${system}.default
        ./configuration.nix
      ];
    };
  };
}
