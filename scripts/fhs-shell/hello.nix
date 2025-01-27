#!/usr/bin/env -S nix-shell --keep miao
let
  pkgs = import <nixpkgs> {};
  fhs = pkgs.buildFHSUserEnv {
    name = "hello";
    targetPkgs = p: with p; [
      hello
    ];
    profile = ''
      export MIAO=1
    '';
  };
in
  fhs.env
