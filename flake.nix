{
  description = "Flake-parts partitions example: local vs release dependency binding";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, self, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.partitions
      ];

      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      # All packages and checks come from the dev partition
      partitionedAttrs = {
        packages = "dev";
        checks = "dev";
      };

      # Partition for projectA standalone (could be used separately)
      partitions.projectA = {
        module = ./projectA/flake-module.nix;
      };

      # Development partition - includes both projects with local dependency
      partitions.dev = {
        # ============================================================
        # TOGGLE BETWEEN THESE TWO OPTIONS:
        # ============================================================

        # Option 1: Use local projectA (for development)
        # Import projectA directly - projectB will use current local version
        module = {
          imports = [
            ./projectA/flake-module.nix
            ./projectB/flake-module.nix
          ];
        };

        # Option 2: Use a pinned release version (for reproducible builds)
        # Uncomment below and comment out the module block above:
        # extraInputsFlake = "github:Padraic-O-Mhuiris/partitions-example/<commit-sha>";
        # module = ./projectB/flake-module.nix;
      };

      perSystem = { pkgs, ... }: {
        devShells.default = pkgs.mkShell {
          name = "partitions-example";
        };
      };
    };
}
