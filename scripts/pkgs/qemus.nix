# build by version
# nix-build pkgs_qemu.nix -A v1_0
# build by date
# nix-build pkgs_qemu.nix -A d2011_12_01
{ pkgs ? import <nixpkgs> {} }:
let
  pname = "qemu";
in rec {
  v1_0 = let
    version = "1.0";
  in pkgs.gcc49Stdenv.mkDerivation {
    inherit pname version;
    src = pkgs.fetchurl {
      url = "https://download.qemu.org/qemu-${version}.tar.xz";
      sha256 = "0y1018xia238pcqb7ad9v299b478c0838fiayl6qkzyd95gk0xbb";
    };
    buildInputs = with pkgs; [
      zlib
      pkg-config
      glib
      python2
    ];
    patches = [
      ./qemu-v1.0.patch
    ];
    configureFlags = [
      "--target-list=x86_64-linux-user"
      "--disable-docs"
    ];
  };
  d2011_12_01 = v1_0;
}
