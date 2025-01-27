#!/usr/bin/env -S nix-build -o coremarks
{pkgs ? import <nixpkgs> {}}:
let
  # function mkCoremark
  mkCoremark = {
    pkgs ? import <nixpkgs> {},
    stdenv ? pkgs.stdenv,
    simple ? false,
  }:
  let
    name = "coremark";
    variant = pkgs.lib.concatStrings [
      "${stdenv.targetPlatform.config}"
      # TODO: all zig-env are static?
      # (if stdenv.targetPlatform.isStatic then ".static" else "")
      (if simple then ".simple" else "")
    ];
  in
  stdenv.mkDerivation {
    inherit name;
    src = pkgs.fetchFromGitHub {
      owner = "eembc";
      repo = "coremark";
      rev = "d26d6fdcefa1f9107ddde70024b73325bfe50ed2";
      sha256 = "0kd6bnrnd3f325ypxzn0w5ii4fmc98h16sbvvjikvzhm78y60wz3";
    };
    preBuild = ''
      # no float point insts
      export CFLAGS="-DHAS_FLOAT=0"

      # simple assumes CC = gcc, this is a bug!
      sed -i '/CC =/d' simple/core_portme.mak
      ${if simple
        then "export PORT_DIR=simple"
        else ""}
    '';
    buildFlags = ["compile"];
    installPhase = ''
      mkdir -p $out/bin
      mv coremark.exe $out/bin/${name}.${variant}.exe
    '';
  };
  zig-env-src = pkgs.fetchFromGitHub {
    owner = "Cloudef";
    repo = "nix-zig-stdenv";
    rev = "6de72ec32ecf0cfb9ad9dab5a8400d532e17f8c5";
    hash = "sha256-hQHOzjkHWO5YxQb3mgZJOfyIuvbiLFocVCMK/A9HTic=";
  };
in
pkgs.symlinkJoin {
  name = "coremarks";
  paths = [
    # x86_64 linux
    (mkCoremark {
      inherit (import zig-env-src {
        target = "x86_64-unknown-linux-gnu";
      }) stdenv;
    })
    # x86_64 linux static
    (mkCoremark {
      inherit (import zig-env-src {
        target = "x86_64-unknown-linux-musl";
      }) stdenv;
    })
    # aarch64 linux
    (mkCoremark {
      inherit (import zig-env-src {
        target = "aarch64-unknown-linux-gnu";
      }) stdenv;
    })
    # aarch64 linux static
    (mkCoremark {
      inherit (import zig-env-src {
        target = "aarch64-unknown-linux-musl";
      }) stdenv;
    })
    # riscv64 linux
    # (mkCoremark {
    #   inherit (import zig-env-src {
    #     target = "riscv64-unknown-linux-gnu";
    #   }) stdenv;
    # })
    # riscv64 linux static
    (mkCoremark {
      inherit (import zig-env-src {
        target = "riscv64-unknown-linux-musl";
      }) stdenv;
    })
    # x86_64 windows
    (mkCoremark {
      inherit (import zig-env-src {
        target = "x86_64-w64-mingw32";
      }) stdenv;
      simple = true;
    })
    # x86_64 darwin can only compiled on x86_64/aarch64 darwin
    #   https://github.com/NixOS/nixpkgs/issues/165804
    # while it is possible compile manually inside darling
    #(mkCoremark {
    #  stdenv = pkgs.pkgsCross.x86_64-darwin.stdenv;
    #})
  ];
}
