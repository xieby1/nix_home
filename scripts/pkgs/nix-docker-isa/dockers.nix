#!/usr/bin/env nix-build
#MC # Instantiatio of nix dockers
#MC
#MC For more details, see [default.nix](./default.nix.md)
{ pkgs ? import <nixpkgs> {}
, ...
}: [
  #MC ## x86_64 docker
  (import ./. {inherit pkgs; pkgsCross=pkgs.pkgsCross.gnu64;})
  #MC ## aarhc64 docker
  (import ./. {inherit pkgs; pkgsCross=pkgs.pkgsCross.aarch64-multiplatform;})
  #MC ## riscv64 docker
  (import ./. {inherit pkgs; pkgsCross=pkgs.pkgsCross.riscv64;})
]
