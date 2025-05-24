{pkgs ?  import <nixpkgs> {} }:
derivation {
  name = "techforum_2025";
  builder = "/bin/sh";
  args = [
    "-c"
    ''
      echo "Hello, Techforum!" | ${pkgs.cowsay}/bin/cowsay > $out
    ''
  ];
  system = builtins.currentSystem;
}