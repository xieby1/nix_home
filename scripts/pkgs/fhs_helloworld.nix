#!/usr/bin/env -S nix-build -o fhs_helloworld

# xieby1: 2022.11.17
# inspired by
#   https://discourse.nixos.org/t/derivation-that-builds-standard-linux-binaries/21557/4
#   https://github.com/NixOS/nixpkgs/compare/master...ElvishJerricco:nixpkgs:run-in-fhs
# TODO-1:
#   I have copy all dependencies to a directory (ld-linux-x86-64.so.2, libc.so)
#   But result cannot run in chroot, error message is `cannot find libc.so`.
# TODO-2:
#   I didn't find a proper package/bundle tool
#   * nix-bundle: not work
#   * appimage: depends on libfuse.so, cannot run directly on nixos

{ pkgs ? import <nixpkgs> {} }:
let
  name = "helloworld";
  fhsEnv = pkgs.buildFHSUserEnv {
    name = "${name}-fhs";
    targetPkgs = pkgs: with pkgs; [
      gcc
      # gcc-unwrapped binutils-unwrapped
      glibc
      glibc.dev
    ];
    # refer to https://discourse.nixos.org/t/using-a-raw-gcc-inside-buildfhsuserenv/12864
    runScript = (pkgs.writeShellScript "${name}-fhsbuilder" ''
      # For gcc-unwrapped and binutils-unwrapped
      # export LIBRARY_PATH=/usr/lib
      # export C_INCLUDE_PATH=/usr/include
      # export CPLUS_INCLUDE_PATH=/usr/include
      # export CMAKE_LIBRARY_PATH=/usr/lib
      # export CMAKE_INCLUDE_PATH=/usr/include
      ## TODO: not work? have to add gcc -Wl,--dynamic-linker=/usr/lib64/ld-linux-x86-64.so.2 ?
      # export LDFLAGS=--dynamic-linker=/usr/lib64/ld-linux-x86-64.so.2

      # For gcc
      export NIX_LDFLAGS="--dynamic-linker=/usr/lib64/ld-linux-x86-64.so.2"
      gcc $src -o $out
    '');
  };
in
builtins.derivation {
  inherit name;
  system = builtins.currentSystem;
  src = builtins.toFile "${name}.c" ''
    #include <stdio.h>
    int main(void) {
      printf("Hello, world! \n");
      return 0;
    }
  '';
  builder = "${fhsEnv}/bin/${fhsEnv.name}";
}
