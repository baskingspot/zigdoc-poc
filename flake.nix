{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.follows = "baskingspot/flake-parts";
    baskingspot = {
      url = "github:baskingspot/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Generates build.zig.zon.nix (`just zon2nix`): the Zig dependencies,
    # transitive ones included, as fixed-output fetches for the package.
    zon2nix = {
      url = "github:jcollie/zon2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = with inputs.baskingspot.flakeModules; [
        base
        zig."0.16"
      ];

      perSystem =
        {
          pkgs,
          config,
          system,
          ...
        }:
        {
          packages = rec {
            zigdoc = pkgs.callPackage ./nix/package.nix { };
            default = zigdoc;
          };

          devShells.default = pkgs.mkShell {
            inputsFrom = with config.devShells; [
              base
              zig
            ];

            packages = [
              pkgs.oxfmt
              inputs.zon2nix.packages.${system}.zon2nix
            ];
          };
        };
    };
}
