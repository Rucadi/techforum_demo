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
    rev = "301bbdf89e258f65123c530adabaf56e5e7d30f3";
    sha256 = "sha256-J4rGxMcVDPg8LZ4dvdNGOPB1Orn+TT3bVoWi0AuuWK4=";
  };

  buildInputs = [
    boost
    sqlite
    xz
  ];
  meta.main_program = pname;

}
