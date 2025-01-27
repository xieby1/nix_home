#!/usr/bin/env -S nix-shell --keep miao
let
  mach-nix = import (builtins.fetchGit {
    url = "https://github.com/DavHau/mach-nix";
    ref = "refs/tags/3.4.0";
  }) {
    pkgs = import <nixpkgs> {};
  };
in
mach-nix.mkPythonShell {
  requirements = ''
    expmcc
  '';
}
