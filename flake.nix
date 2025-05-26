{
  description = "C++ Integration Demo with Boost, SQLite, and XZ";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
    nixbundlers.url = "github:NixOS/bundlers";
    bombon.url = "github:rucadi/bombon";
    bombon.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs,  nixbundlers, bombon, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in rec{
        packages.default = pkgs.callPackage ./packages/package_cmake.nix {};
        packages.complex = pkgs.pkgsStatic.callPackage ./packages/package_manual.nix {};
        packages.static = pkgs.pkgsStatic.callPackage ./packages/package_manual.nix {};
        packages.docker_image = pkgs.callPackage ./packages/package_docker.nix {techforum_app = packages.default;};
        packages.docker_image_static = pkgs.callPackage ./packages/package_docker.nix {techforum_app = packages.static;};
        packages.sunshine = pkgs.callPackage ./packages/package_sunshine.nix {};


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

        devShells.default = import ./shell/shell.nix { inherit pkgs; };
      }
    );
}