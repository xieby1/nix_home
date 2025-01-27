#!/usr/bin/env -S nix-shell --keep miao
# xieby1: 2022.07.03
# let
#   pkgs = import <nixpkgs> {};
# in
# pkgs.mkShell {
#   buildInputs = [
#     pkgs.pkgsCross.mipsel-linux-gnu.stdenv.cc
#   ];
# }

# xieby1: 2022.05.16
let
  pkgs_mips_cross = import <nixpkgs> {
    crossSystem = "mips-linux";
  };
  pkgs = import <nixpkgs> {};
in
pkgs.mkShell {
  buildInputs = (with pkgs_mips_cross; [
    buildPackages.gdb
    buildPackages.gcc
  ]) ++ (with pkgs; [
    qemu
  ]);
}
