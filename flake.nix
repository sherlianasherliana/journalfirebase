{
  description = "Flutter + Android build environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [
        pkgs.jdk17
        pkgs.zip
        pkgs.unzip
        pkgs.git
      ];

      JAVA_HOME = pkgs.jdk17;
    };
  };
}
