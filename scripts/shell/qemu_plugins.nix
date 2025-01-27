#!/usr/bin/env -S nix-shell --keep miao
# lxy's qemu plugins: http://172.17.103.58/lixinyu/qemu_plugins

let
  pkgs = import <nixpkgs> {};
in pkgs.mkShell {
  packages = with pkgs; [
    zlib.dev
    pkg-config
    glib.dev
  ];
  QEMU_DIR = "~/Codes/qemu";
}
