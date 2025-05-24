{
  description = "C++ Integration Demo with Boost, SQLite, and XZ";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
    nixbundlers.url = "github:NixOS/bundlers";
    bombon.url = "github:nikstur/bombon";
    bombon.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixbundlers, bombon, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in rec{
        packages.default = pkgs.callPackage ./package.nix {};
        packages.complex = pkgs.pkgsStatic.callPackage ./package_complex.nix {};
        packages.static = pkgs.pkgsStatic.callPackage ./package.nix {};
        bundlers = {
          # Use the official toRPM bundler
          toRPM = nixbundlers.bundlers.${system}.toRPM;
          
          # Use the official toDEB bundler
          toDEB = nixbundlers.bundlers.${system}.toDEB;
        };

        packages.rpm = bundlers.toRPM packages.default;
        packages.static_rpm = bundlers.toRPM packages.static;
        packages.deb = bundlers.toDEB packages.default;
        packages.static_deb = bundlers.toDEB packages.static;

        packages.sbom = bombon.lib.${system}.buildBom packages.default {};

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            boost
            sqlite
            xz
            gcc
            gnumake
            jq
          ];
          
          shellHook = let 
            sbom_file = packages.sbom;
          in ''
            echo "C++ Integration Demo Development Environment"
            echo "Dependencies: Boost, SQLite, and XZ"
            echo "link attrs: -lboost_system -lsqlite3 -llzma -lstdc++fs"
            echo "Build command: $CXX -std=c++17 src/main.cpp -o integration_demo -lboost_system -lsqlite3 -llzma"
            echo "Run command: ./integration_demo"

            function sbom_lic() {
              jq -r '[.metadata.component.purl, (.components[] | .purl + "\n" + (.licenses[0].license.id // "NO LICENSE FOUND"))] | join("\n")' ${sbom_file}
            }

            function sbom_deps(){
              jq -r '[.metadata.component.purl, (.components[] | .purl)] | join("\n")' ${sbom_file}
            }

            function build()
            {
              $CXX -std=c++17 src/main.cpp \
                -o integration_demo \
                -lboost_system \
                -lsqlite3 \
                -llzma \
                -lstdc++fs
            }

            function run()
            {
              ./integration_demo
            }

            function clean()
            {
              rm -f integration_demo
            }

            function sbom()
            {
              cat ${sbom_file} | jq 
            }

          '';
        };
      }
    );
}