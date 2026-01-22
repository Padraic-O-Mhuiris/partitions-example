{
  description = "Monorepo with dependency chain A -> B -> C -> D";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Pinned upstream releases - each can point to different commits/tags
    # These are optional - comment out until first release of each
    # upstream-A.url = "github:Padraic-O-Mhuiris/partitions-example/projectA-v1.0.0";
    # upstream-B.url = "github:Padraic-O-Mhuiris/partitions-example/projectB-v1.0.0";
    # upstream-C.url = "github:Padraic-O-Mhuiris/partitions-example/projectC-v1.0.0";
    # upstream-D.url = "github:Padraic-O-Mhuiris/partitions-example/projectD-v1.0.0";
  };

  outputs = inputs @ {
    flake-parts,
    self,
    ...
  }: let
    # Package versions - bump these when releasing
    versions = {
      A = "1.0.0";
      B = "1.0.0";
      C = "1.0.0";
      D = "1.0.0";
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
        lib,
        self',
        inputs',
        ...
      }: let
        # Helper to create a proper package with version metadata
        mkProject = {
          name,
          version,
          deps ? [],
        }:
          pkgs.stdenv.mkDerivation {
            pname = name;
            inherit version;

            dontUnpack = true;

            buildInputs = deps;

            installPhase = let
              depCalls = lib.concatMapStringsSep "\n" (dep: ''
                ${dep}/bin/${dep.pname} | sed 's/^/    /'
              '') deps;
            in ''
              mkdir -p $out/bin
              cat > $out/bin/${name} << 'EOF'
              #!/usr/bin/env bash
              echo "${name} v${version}"
              EOF
              ${lib.optionalString (deps != []) ''
                echo 'echo "  depends on:"' >> $out/bin/${name}
                cat >> $out/bin/${name} << 'DEPS'
                ${depCalls}
              DEPS
              ''}
              chmod +x $out/bin/${name}
            '';

            meta = {
              description = "Project ${name}";
              mainProgram = name;
            };
          };

        # Dependency chain: D -> C -> B -> A
        # Local builders
        localA = mkProject {
          name = "projectA";
          version = versions.A;
        };

        localB = mkProject {
          name = "projectB";
          version = versions.B;
          deps = [A];
        };

        localC = mkProject {
          name = "projectC";
          version = versions.C;
          deps = [B];
        };

        localD = mkProject {
          name = "projectD";
          version = versions.D;
          deps = [C];
        };

        # Select local or upstream based on localDepth
        A =
          if localDepth >= 4
          then localA
          else inputs'.upstream-A.packages.projectA or localA;

        B =
          if localDepth >= 3
          then localB
          else inputs'.upstream-B.packages.projectB or localB;

        C =
          if localDepth >= 2
          then localC
          else inputs'.upstream-C.packages.projectC or localC;

        D =
          if localDepth >= 1
          then localD
          else inputs'.upstream-D.packages.projectD or localD;

        # Release script for tagging and pushing
        releaseScript = pkgs.writeShellScriptBin "release" ''
          set -euo pipefail

          if [ $# -ne 1 ]; then
            echo "Usage: release <A|B|C|D>"
            echo "Example: release A"
            exit 1
          fi

          PROJECT="$1"
          case "$PROJECT" in
            A) VERSION="${versions.A}" ;;
            B) VERSION="${versions.B}" ;;
            C) VERSION="${versions.C}" ;;
            D) VERSION="${versions.D}" ;;
            *)
              echo "Invalid project: $PROJECT (must be A, B, C, or D)"
              exit 1
              ;;
          esac

          TAG="project$PROJECT-v$VERSION"

          echo "Releasing project$PROJECT version $VERSION"
          echo "Tag: $TAG"
          echo ""

          # Check for uncommitted changes
          if ! git diff-index --quiet HEAD --; then
            echo "Error: You have uncommitted changes. Please commit first."
            exit 1
          fi

          # Check if tag already exists
          if git rev-parse "$TAG" >/dev/null 2>&1; then
            echo "Error: Tag $TAG already exists"
            exit 1
          fi

          echo "Creating tag $TAG..."
          git tag -a "$TAG" -m "Release project$PROJECT v$VERSION"

          echo "Pushing tag to origin..."
          git push origin "$TAG"

          echo ""
          echo "Done! Now update flake.nix upstream-$PROJECT input to point to $TAG"
          echo "Then run: nix flake lock --update-input upstream-$PROJECT"
        '';
      in {
        packages = {
          projectA = A;
          projectB = B;
          projectC = C;
          projectD = D;
          release = releaseScript;
        };

        devShells.default = pkgs.mkShell {
          name = "partitions-example";
          packages = [releaseScript];
        };
      };
    };
}
