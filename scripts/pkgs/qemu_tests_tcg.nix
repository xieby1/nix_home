#!/usr/bin/env nix-build
# TODO
# Ref: ~/Documents/Tech/BT/QEMU/test.md
let
  pkgs = import <nixpkgs> {};
in
pkgs.stdenv.mkDerivation {
  buildInputs = with pkgs; [
    # configure needs
    ninja
    pkg-config
    glib
    # make needs
    glibc.static # TODO: this will cause configure failed
  ];
  buildFlags = [
    "CFLAGS=-O" # override CFLAGS
    "build-tcg-tests-x86_64-linux-user"
  ];
}
