# projectB/default.nix
# projectA comes from extraInputsFlake (local ./projectA or release from inputs.nix)
{lib, inputs, ...}: let
  _ = builtins.trace "projectB inputs: ${builtins.toString (builtins.attrNames inputs)}" null;
in {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: let
    __ = builtins.trace "projectB inputs': ${builtins.toString (builtins.attrNames inputs')}" null;
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
