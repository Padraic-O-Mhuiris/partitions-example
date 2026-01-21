{
  description = "Monorepo with overlay for previous version refs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Previous released version of this repo
    projectA-upstream.url = "github:Padraic-O-Mhuiris/partitions-example";
  };

  outputs = inputs @ {
    flake-parts,
    self,
    ...
  }: let
    # Toggle: true = use upstream, false = use local
    useUpstream = false;
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];

      perSystem = {
        pkgs,
        system,
        self',
        ...
      }: let
        projectA =
          if useUpstream
          then inputs.projectA-upstream.packages.${system}.projectA
          else self'.packages.projectA;
      in {
        packages = {
          projectA = pkgs.writeShellScriptBin "projectA" ''
            echo "projectA v0.2.0-dev"
          '';

          projectB = pkgs.writeShellScriptBin "projectB" ''
            echo "projectB"
            echo "Using projectA:"
            ${projectA}/bin/projectA
          '';
        };

        devShells.default = pkgs.mkShell {
          name = "partitions-example";
        };
      };
    };
}
