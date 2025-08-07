{
  inputs = {
    naersk.url = "github:nix-community/naersk/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      utils,
      naersk,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        naersk-lib = pkgs.callPackage naersk { };
        runtimeDependencies = with pkgs; [
          # chafa
        ];
      in
      {
        defaultPackage = naersk-lib.buildPackage {
          src = ./.;
          meta.mainProgram = "rofi-nerdy";

          nativeBuildInputs = with pkgs; [
            pkg-config
            pango
          ];
          cargoBuildOptions = opt: opt ++ [ "--lib" ];
          postInstall = ''
            mkdir -p $out/lib/rofi
            cp target/release/lib*.so $out/lib/rofi || true
          '';

        };
        devShell =
          with pkgs;
          mkShell {
            buildInputs = [
              cargo
              rustc
              rustfmt
              pre-commit
              rustPackages.clippy
              bacon
            ]
            ++ runtimeDependencies;

            RUST_SRC_PATH = rustPlatform.rustLibSrc;
          };
      }
    );
}
