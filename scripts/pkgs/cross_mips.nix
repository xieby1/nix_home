#!/usr/bin/env -S nix-env -i -f
# xieby1: 2022.05.16
with (import <nixpkgs> {crossSystem = "mips-linux";}); {
  gdb = lib.lowPrio buildPackages.gdb;
  gcc = lib.lowPrio buildPackages.gcc;
}
