#!/usr/bin/env -S nix-shell --keep miao
{ pkgs ? import <nixpkgs> {} }:
let
  pin = builtins.derivation {
    name = "pin-3.25";
    system = builtins.currentSystem;
    src = pkgs.fetchurl {
      url = "https://software.intel.com/sites/landingpage/pintool/downloads/pin-3.25-98650-g8f6168173-gcc-linux.tar.gz";
      hash = "sha256-Q8D0QSNLDly2XK+XFOYdMxbx5N33eGVzESGTCgWGX6E=";
    };
    builder = pkgs.writeShellScript "pin-builder" ''
      # make mkdir and tar and other useful tools added to PATH
      source ${pkgs.stdenv}/setup
      mkdir -p $out
      # strip leading directory
      tar -xf $src --strip-components=1 --directory=$out
    '';
  };
in
(pkgs.buildFHSUserEnv {
  name = "pin";
  targetPkgs = pkgs: with pkgs; [
  ];
  profile = ''
    PATH+=":${pin}"
  '';
}).env
