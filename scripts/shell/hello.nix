#!/usr/bin/env -S nix-shell --keep miao
with import <nixpkgs> {};
# You will get a shell with hello executable,
# and environment variable $name, $miao.
mkShell {
  packages = [
    hello
  ];
  name = "test-env";
  miao = "miao!";
}
