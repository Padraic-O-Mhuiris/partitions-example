# projectB/default.nix
{ lib, ... }:
let
  # TOGGLE: true = local, false = release
  useLocal = true;

  releaseFlake = "github:Padraic-O-Mhuiris/partitions-example/844c8892e167e2c77c5de7b058b6ad4ece667600";
in
{
  imports = lib.optionals useLocal [
    ../projectA
  ];

  perSystem = { pkgs, self', ... }:
    let
      projectA =
        if useLocal
        then self'.packages.projectA
        else (builtins.getFlake releaseFlake).packages.${pkgs.system}.projectA;
    in
    {
      packages.projectB = pkgs.writeShellScriptBin "projectB" ''
        echo "projectB"
        echo "Using:"
        ${projectA}/bin/projectA
      '';

      checks.projectB-integration = pkgs.runCommand "projectB-integration-test" { } ''
        ${projectA}/bin/projectA > $out
        echo "projectB integration test passed" >> $out
      '';
    };
}
