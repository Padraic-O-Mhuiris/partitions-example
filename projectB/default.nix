# projectB/default.nix
# projectA comes from extraInputsFlake (local ./projectA or release from inputs.nix)
{lib, inputs, ...}: {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: let
    projectA = inputs'.self.packages.projectA;
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
