# projectA/default.nix
{ lib, ... }:
let
  version = "0.2.0-dev";
in
{
  perSystem = { pkgs, ... }: {
    packages.projectA = pkgs.writeShellScriptBin "projectA" ''
      echo "projectA v${version}"
    '';
  };
}
