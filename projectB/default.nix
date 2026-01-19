# projectB/default.nix
# projectA comes from extraInputsFlake (./projectB/flake.nix inputs.projectA)
{lib, inputs, ...}: {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: let
    projectA = inputs'.projectA.packages.projectA;
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
