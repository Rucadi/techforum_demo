let
  import_specific_commit =
    commit:
    import (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/${commit}.tar.gz";
    }) { };
  git_nixpkgs = import_specific_commit "21808d22b1cda1898b71cf1a1beb524a97add2c4";
  python3_nixpkgs = import_specific_commit "42acb5dc55a754ef074cb13e2386886a2a99c483";
  nodejs_nixpkgs = import_specific_commit "c0c50dfcb70d48e5b79c4ae9f1aa9d339af860b4";
  clang_nixpkgs = import_specific_commit "21808d22b1cda1898b71cf1a1beb524a97add2c4";
  stdenv_nixpkgs = import_specific_commit "21808d22b1cda1898b71cf1a1beb524a97add2c4";
in
stdenv_nixpkgs.mkShell {
  name = "environment";
  buildInputs = [
    git_nixpkgs.git
    python3_nixpkgs.python3
    nodejs_nixpkgs.nodejs-7_x
    clang_nixpkgs.llvmPackages_15.clang
  ];
  shellHook = ''
    # Python3 old versions are "special" :)
    export LC_ALL=C
    # show all programs versions
    echo "git version: $(git --version)"
    echo "python3 version: $(python3 --version)"
    echo "nodejs version: $(node --version)"
    echo "clang version: $(clang --version)"
  '';
  LOCALE_ARCHIVE = "${stdenv_nixpkgs.glibcLocales}/lib/locale/locale-archive";

}
