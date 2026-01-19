{
  description = "Project A";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];

      imports = [
        ./default.nix
      ];

      perSystem = {self', pkgs, ...}: {
        devShells.default = pkgs.mkShell {
          name = "projectA";
          packages = [
            self'.packages.projectA
          ];
        };
      };
    };
}
