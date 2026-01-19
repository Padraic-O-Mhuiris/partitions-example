{
  description = "Monorepo with projectA and projectB";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    projectA.url = "path:./projectA";
    projectB.url = "path:./projectB";
  };

  outputs = inputs @ {flake-parts, projectA, projectB, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];

      perSystem = {pkgs, system, ...}: {
        packages = {
          inherit (projectA.packages.${system}) projectA;
          inherit (projectB.packages.${system}) projectB;
        };

        checks = {
          inherit (projectB.checks.${system}) projectB-integration;
        };

        devShells.default = pkgs.mkShell {
          name = "partitions-example";
          packages = [
            projectA.packages.${system}.projectA
            projectB.packages.${system}.projectB
          ];
        };
      };
    };
}
