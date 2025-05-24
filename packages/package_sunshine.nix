{ lib, stdenv, fetchFromGitHub, gnused, python3, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "sunshine";
  version = "add307a9cdca3b32a126a9da0c872f31edf0b7ff"; 

  src = fetchFromGitHub {
    owner = "CycloneDX";
    repo = "Sunshine";
    rev = version;
    sha256 = "sha256-8QFbXMcv+DPDO2+6/nWmFmLPDL52+snqUcI5EGxu2O4=";
  };

  nativeBuildInputs = [ gnused ];
  propagatedBuildInputs = with python3Packages; [ requests ];

  format = "other";
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp sunshine.py $out/bin/sunshine
    # add shebang to the script
    sed -i '1s|^|#!/usr/bin/env python3\n|' $out/bin/sunshine
    chmod +x $out/bin/sunshine
  '';

  meta = with lib; {
    description = "Actionable CycloneDX visualization tool";
    homepage = "https://github.com/CycloneDX/Sunshine";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
