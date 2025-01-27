#!/usr/bin/env nix-build
let
  pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/e60c3e2abb8ae9df3d89820c706cc736fad01ff7.tar.gz";
    sha256 = "0vyjpf1jw4cvw7kfbk055faq08q4swz6v1h2mf9zw4r8frhqa73w";
  }) {};
in
pkgs.pkgsCross.aarch64-multiplatform.pkgsStatic.glib
