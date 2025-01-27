#!/usr/bin/env -S nix-shell --keep miao
{ pkgs ? import <nixpkgs> {} }:
(pkgs.buildFHSUserEnv {
  name = "dynamoRIO";
  targetPkgs = pkgs: with pkgs; [
    (hiPrio gcc)
    snappy
    zlib
    zlib.dev
    lz4
    lz4.dev
    libunwind
    libunwind.dev
  ];
  profile = ''
    export CC=gcc
    export CXX=g++
  '';
}).env
