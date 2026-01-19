{
  description = "Monorepo with projectA and projectB partitions";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    flake-parts,
    self,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      # debug = true;
      imports = [
        inputs.flake-parts.flakeModules.partitions

        ({config, ...}: {
          flake.xxx = {
            inherit config;
          };
        })
      ];

      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];

      # partitionedAttrs = {
      #   packages = "projectA";
      #   checks = "projectB";
      # };

      partitions.projectA = {
        extraInputsFlake = ./projectA;
        module = ./projectA;
      };

      partitions.projectB = {
        extraInputsFlake = ./projectB;
        module = ./projectB;
      };

      perSystem = {pkgs, ...}: {
        devShells.default = pkgs.mkShell {
          name = "partitions-example";
        };
      };
    };
}
