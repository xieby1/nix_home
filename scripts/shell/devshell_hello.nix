#!/usr/bin/env -S nix-shell --keep miao
{ system ? builtins.currentSystem }:
let
  src = fetchTarball {
    url = "https://github.com/numtide/devshell/archive/9fddc998b4522694caaf4056e93154d2c11752cd.tar.gz";
    sha256 = "0d7ra00843n4iyadhdxcr9m0vcn6fz54hfymms6nbdz0d2pjff06";
  };
  devshell = import src { inherit system; };
in
devshell.mkShell {
  commands = [{
    name = "hello";
    command = "echo hello";
    help = "print hello miao";
  }];
}
