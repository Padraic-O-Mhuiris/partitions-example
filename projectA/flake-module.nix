# projectA/flake-module.nix
# A simple subproject that exposes a package and library attribute
{ lib, ... }:
let
  version = "0.1.0";
in
{
  perSystem = { pkgs, system, ... }: {
    packages.projectA = pkgs.writeShellScriptBin "projectA" ''
      echo "projectA v${version}"
    '';
  };
}
