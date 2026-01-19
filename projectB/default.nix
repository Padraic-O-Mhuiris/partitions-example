# projectB/default.nix
# projectA comes from:
# - extraInputsFlake (local): inputs'.self.packages.projectA
# - extraInputs (release): inputs'.projectA-release.packages.projectA
{lib, inputs, ...}: {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: let
    projectA =
      if inputs' ? projectA-release
      then inputs'.projectA-release.packages.projectA
      else inputs'.self.packages.projectA;
  in {
    packages.projectB = pkgs.writeShellScriptBin "projectB" ''
      echo "projectB"
      echo "Using:"
      ${projectA}/bin/projectA
    '';

    checks.projectB-integration = pkgs.runCommand "projectB-integration-test" {} ''
      ${projectA}/bin/projectA > $out
      echo "projectB integration test passed" >> $out
    '';
  };
}
