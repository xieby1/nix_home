#!/usr/bin/env -S nix-shell --keep miao
with import <nixpkgs> {};
mkShell {
  packages = [
    dtc
    pkgsCross.riscv64-embedded.stdenv.cc
  ];
  name = "spike";
}
