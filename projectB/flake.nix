{
  description = "Project B";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Toggle between local and release:
    # projectA.url = "path:../projectA";
    projectA.url = "github:Padraic-O-Mhuiris/partitions-example/844c8892e167e2c77c5de7b058b6ad4ece667600?dir=projectA";
  };

  outputs = {
    nixpkgs,
    projectA,
    ...
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system} system);
  in {
    packages = forAllSystems (pkgs: system: {
      projectB = pkgs.writeShellScriptBin "projectB" ''
        echo "projectB"
        echo "Using:"
        ${projectA.packages.${system}.projectA}/bin/projectA
      '';
      default = pkgs.writeShellScriptBin "projectB" ''
        echo "projectB"
        echo "Using:"
        ${projectA.packages.${system}.projectA}/bin/projectA
      '';
    });

    checks = forAllSystems (pkgs: system: {
      projectB-integration = pkgs.runCommand "projectB-integration-test" {} ''
        ${projectA.packages.${system}.projectA}/bin/projectA > $out
        echo "projectB integration test passed" >> $out
      '';
    });

    devShells = forAllSystems (pkgs: system: {
      default = pkgs.mkShell {
        name = "projectB";
      };
    });
  };
}
