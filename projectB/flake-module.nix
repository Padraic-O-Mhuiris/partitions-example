# projectB/flake-module.nix
# Depends on projectA - can be built against local or release version
{ lib, config, inputs, ... }:
{
  perSystem = { pkgs, system, self', ... }:
    let
      # Access projectA from either:
      # - self' (when projectA is imported locally in the same partition)
      # - inputs.self (when using extraInputsFlake with a remote release)
      projectAPackage =
        if self' ? packages.projectA
        then self'.packages.projectA
        else inputs.self.packages.${system}.projectA;
    in
    {
      packages.projectB = pkgs.writeShellScriptBin "projectB" ''
        echo "projectB"
        echo "Using:"
        ${projectAPackage}/bin/projectA
      '';

      # A check to verify the dependency is working
      checks.projectB-integration = pkgs.runCommand "projectB-integration-test" { } ''
        ${projectAPackage}/bin/projectA > $out
        echo "projectB integration test passed" >> $out
      '';
    };
}
