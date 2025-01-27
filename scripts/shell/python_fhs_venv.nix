# https://nixos.wiki/wiki/Python
# Python virtual environment

# Execute this commands after entering fhs env
# python -m venv .venv
# source .venv/bin/activate

let
  pkgs = import <nixpkgs> {};
in (pkgs.buildFHSUserEnv {
  name = "venv";
  targetPkgs = p: (with p.python3Packages; [
    pip
    virtualenv
    ipython
  ]);
}).env
