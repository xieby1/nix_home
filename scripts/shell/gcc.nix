#!/usr/bin/env -S nix-shell --keep miao
let
  pkgs = import <nixpkgs> {};
in pkgs.mkShellNoCC {
  name = "gcc11";
  packages = with pkgs; [
    gcc11
  ];
}
