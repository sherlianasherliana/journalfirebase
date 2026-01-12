{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.jdk17
    pkgs.zip
    pkgs.unzip
    pkgs.git
  ];

  JAVA_HOME = "${pkgs.jdk17}";
}
