#!/usr/bin/env -S nix-shell --keep miao
#2022.05.18
# pip install is usable in venv
# e.g.
# $ nix-shell <this_file>
# $ pip install [--user] graphviz2drawio
let
  pkgs = import <nixpkgs> {};
in
pkgs.mkShell {
  propagatedBuildInputs = with pkgs.python3Packages; [
    pip
    venvShellHook
    ipython
  ];
  venvDir = "${builtins.getEnv "HOME"}/.venv";
}
