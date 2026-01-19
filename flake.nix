{
  description = "Flake-parts partitions example: local vs release dependency binding";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.flake-parts.flakeModules.partitions
      ];

      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];

      # partitionedAttrs = {
      #   packages = "projectA";
      #   checks = "projectB";
      # };

      # partitions.projectA.module = ./projectA;
      # partitions.projectB.module = ./projectB;

      perSystem = {pkgs, ...}: {
        devShells.default = pkgs.mkShell {
          name = "partitions-example";
        };
      };
    };
}
