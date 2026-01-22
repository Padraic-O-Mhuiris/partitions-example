{
  description = "Monorepo with dependency chain A -> B -> C -> D";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Pinned upstream releases (update these refs for new releases)
    upstream.url = "github:Padraic-O-Mhuiris/partitions-example";
  };

  outputs = inputs @ {
    flake-parts,
    self,
    ...
  }: let
    # Package versions
    versions = {
      A = "1.0.0";
      B = "2.1.0";
      C = "0.5.0";
      D = "3.0.0-dev";
    };

    # "Window" into the dependency chain: how deep to use local packages
    # 0 = all upstream (released)
    # 1 = D local, rest upstream
    # 2 = D,C local, rest upstream
    # 3 = D,C,B local, A upstream
    # 4 = all local
    localDepth = 4;
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];

      perSystem = {
        pkgs,
        self',
        inputs',
        ...
      }: let
        up = inputs'.upstream.packages;

        # Dependency chain: D -> C -> B -> A
        # Each level checks if it's within the local window
        A =
          if localDepth >= 4
          then
            pkgs.writeShellScriptBin "projectA" ''
              echo "projectA v${versions.A} (local)"
            ''
          else up.projectA;

        B =
          if localDepth >= 3
          then
            pkgs.writeShellScriptBin "projectB" ''
              echo "projectB v${versions.B} (local)"
              echo "  depends on:"
              ${A}/bin/projectA | sed 's/^/    /'
            ''
          else up.projectB;

        C =
          if localDepth >= 2
          then
            pkgs.writeShellScriptBin "projectC" ''
              echo "projectC v${versions.C} (local)"
              echo "  depends on:"
              ${B}/bin/projectB | sed 's/^/    /'
            ''
          else up.projectC;

        D =
          if localDepth >= 1
          then
            pkgs.writeShellScriptBin "projectD" ''
              echo "projectD v${versions.D} (local)"
              echo "  depends on:"
              ${C}/bin/projectC | sed 's/^/    /'
            ''
          else up.projectD;
      in {
        packages = {
          projectA = A;
          projectB = B;
          projectC = C;
          projectD = D;
        };

        devShells.default = pkgs.mkShell {
          name = "partitions-example";
        };
      };
    };
}
