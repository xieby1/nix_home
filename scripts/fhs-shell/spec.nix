#!/usr/bin/env -S nix-shell --keep miao
{ pkgs ? import <nixpkgs> {} }:
let
  zigenv = import /home/xieby1/Codes/nix-zig-stdenv {
    target = "x86_64-unknown-linux-musl";
  };
  noPrefixStaticStdenvCC = pkgs.runCommand "linkCC" {} ''
    mkdir -p $out/bin
    for file in ${pkgs.pkgsStatic.stdenv.cc}/bin/*; do
      ln -s $file $out/bin/''${file##*-}
    done
  '';
in
(pkgs.buildFHSUserEnv {
  name = "spec";
  targetPkgs = pkgs: with pkgs; [
    # (hiPrio zigenv.pkgs.stdenv.cc)
    # (hiPrio clangStdenv.cc)
    # (hiPrio gcc)
    # (hiPrio pkgsStatic.stdenv.cc)
    # noPrefixStaticStdenvCC
    gfortran
    # uclibc
    # musl
    # musl.dev
    glibc.static
    glibc.dev
  ];
}).env
