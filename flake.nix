{
  description = "Flake-parts partitions example: local vs release dependency binding";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {flake-parts, ...}: let
    projectBInputs = import ./projectB/inputs.nix;
    _ = builtins.trace "projectBInputs: ${builtins.toJSON projectBInputs}" null;
    useRelease = projectBInputs ? projectA;
    __ = builtins.trace "useRelease: ${builtins.toJSON useRelease}" null;
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.flake-parts.flakeModules.partitions
      ];

      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];

      partitionedAttrs = {
        packages = "projectA";
        checks = "projectB";
      };

      partitions.projectA = {
        extraInputsFlake = ./projectA;
        module = ./projectA;
      };

      partitions.projectB =
        if useRelease
        then {
          # Release: fetch from pinned flake ref
          extraInputsFlake = projectBInputs.projectA;
          module = ./projectB;
        }
        else {
          # Local: use subflake path
          extraInputsFlake = ./projectA;
          module = ./projectB;
        };

      perSystem = {pkgs, ...}: {
        devShells.default = pkgs.mkShell {
          name = "partitions-example";
        };
      };
    };
}
