#!/usr/bin/env -S nix-shell --keep miao
let
  pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/5e15d5da4abb74f0dd76967044735c70e94c5af1.tar.gz";
    sha256 = "0mk86mlxamjxhywdfp5asylqb39z7w18dcy8ds6qvl8gqjrijmq9";
  }) {
    system = "x86_64-linux";
  };
in pkgs.mkShell {
  name = "wine6";
  packages = with pkgs; [
    wine64
  ];
}
