{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    boost
    sqlite
    xz
    gcc
    gnumake
    jq
    grype
  ];

  shellHook = ''
    echo "C++ Integration Demo Development Environment"
    echo "Dependencies: Boost, SQLite, and XZ"
    echo "link attrs: -lboost_system -lsqlite3 -llzma -lstdc++fs"
    echo "Build command: $CXX -std=c++17 src/main.cpp -o integration_demo -lboost_system -lsqlite3 -llzma"
    echo "Run command: ./integration_demo"
    echo "Docker load: docker load -i $(nix build .#docker_image --no-link --print-out-paths 2>/dev/null)"
    echo "Check vulnerabilities: grype --add-cpes-if-none $(nix build .#sbom --no-link --print-out-paths 2>/dev/null)"

    function sbom_lic() {

      jq -r '[.metadata.component.purl, (.components[] | .purl + "\n" + (.licenses[0].license.id // "NO LICENSE FOUND"))] | join("\n")' $1
    }

    function sbom_deps(){
      jq -r '[.metadata.component.purl, (.components[] | .purl)] | join("\n")' $1
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

  '';
}
