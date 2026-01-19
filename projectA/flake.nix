{
  description = "Project A";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {nixpkgs, ...}: let
    systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    version = "0.1.0";
  in {
    packages = forAllSystems (pkgs: {
      projectA = pkgs.writeShellScriptBin "projectA" ''
        echo "projectA v${version}"
      '';
      default = pkgs.writeShellScriptBin "projectA" ''
        echo "projectA v${version}"
      '';
    });

    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        name = "projectA";
      };
    });
  };
}
