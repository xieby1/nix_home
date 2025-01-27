let
  name = "chipyard";
  pkgs = import <nixpkgs> {};
  pkgsCirct1_30_0 = import (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/0aca8f43c8dba4a77aa0c16fb0130237c3da514c.tar.gz";
  }) {};

  # currently latest spike
  my-spike = pkgs.spike.overrideAttrs (old: {
    version = "1.1.1-dev";
    src = pkgs.fetchFromGitHub {
      owner = "riscv";
      repo = "riscv-isa-sim";
      rev = "4f916978cd17bd2e83cfca233d0fa40153fda5f4";
      sha256 = "sha256-84YY9YMIa4YO5mVJ0gGMOWnD2/CnpEjIbB9EjA5+Glc=";
    };
  });

  h_content = builtins.toFile "h_content" ''
    # ${pkgs.lib.toUpper "${name} usage tips"}

    The conda cannot gracefully manage the dependencies, e.g. gcc's dynamic libraries.
    Instead, I replace conda with nix to manage the dependencies.

    * Show this help: `h`

    Init Repos

    * edit common.mk:1 `SHELL=bash`
    * `./scripts/init-submodules-no-riscv-tools-nolog.sh`

    Compiling Verilator

    * `make -C sims/verilator`

    Run Verilator

    * `./sims/verilator/simulator-chipyard.harness-RocketConfig <RISCV Executable>`
  '';
  _h_ = pkgs.writeShellScriptBin "h" ''
    ${pkgs.glow}/bin/glow ${h_content}
  '';
in pkgs.mkShell {
  inherit name;
  packages = with pkgs; [
    verilator
    dtc
    jq
    pkgsCirct1_30_0.circt
    my-spike

    _h_
  ];
  shellHook = ''
    export RISCV=${pkgs.pkgsCross.riscv64-embedded.stdenv.cc}

    h
  '';
}
