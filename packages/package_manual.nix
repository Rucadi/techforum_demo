{
  boost,
  sqlite,
  xz,
  stdenv,
  fetchFromGitHub
}:
stdenv.mkDerivation rec {
  pname = "integration_demo";
  name = "cpp-integration-demo";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "rucadi";
    repo = "techforum_app";
    rev = "f46b93f591c05109455eac57e34ae9905723524b";
    sha256 = "sha256-AtrvV7E/od9753evcriq2/GUrG0hSewu0BQ5PzH7ZYg=";
  };

  buildInputs = [
    boost
    sqlite
    xz
  ];

  # unpackPhase
  # patchPhase
  # buildPhase
  buildPhase = ''
    $CXX -std=c++17 src/main.cpp \
     -o ${pname} \
     -lboost_system \
     -lsqlite3 \
     -llzma

     env > cmd.log
  '';

  # installPhase
  installPhase = ''
    mkdir -p $out/bin
    cp ${pname} $out/bin/
    cp cmd.log $out/
  '';
  meta.main_program = pname;

}
