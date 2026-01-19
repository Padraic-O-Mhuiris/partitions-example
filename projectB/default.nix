# projectB/default.nix
{
  lib,
  inputs,
  ...
}: let
in {
  perSystem = {
    pkgs,
    system,
    ...
  }: let
    # projectA = effectiveSelf.packages.${system}.projectA;
  in {
    packages.projectB = pkgs.writeShellScriptBin "projectB" ''
      echo "projectB"
      echo "Using:"
    '';

    # checks.projectB-integration = pkgs.runCommand "projectB-integration-test" {} ''
    #   ${projectA}/bin/projectA > $out
    #   echo "projectB integration test passed" >> $out
    # '';
  };
}
