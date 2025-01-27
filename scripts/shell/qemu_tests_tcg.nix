#!/usr/bin/env -S nix-shell --keep miao
# --pure: start a pure reproducible shell
# 2022.04.24
# Compile qemu/tests/tcg/x86_64/
# env CFLAGS=-O make -e build-tcg-tests-x86_64-linux-user
{ pkgs ? import <nixpkgs> {} }:
let
  name = "nix";
in
pkgs.mkShell {
  inherit name;
  buildInputs = with pkgs; [
    glibc.static
  ];
  inputsFrom = with pkgs; [
    qemu
  ];
}
