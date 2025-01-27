#!/usr/bin/env -S nix-build -o nix-binary-tarballs
#MC # Nix official installer (new)
#MC
#MC Use nix (>2.18) binary-tarball script, which has not been merged into mainline nixpkgs.
#MC
#MC See [nix-binary-tarballs.nix](./nix-binary-tarballs.nix.md) for current nix binary-tarball script.
let
  pkgs = import <nixpkgs> {};
  nix_src = pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nix";
    rev = "d0c7da131fb64526bc72144949b6955c25367d92";
    hash = "sha256-Z4RlluZjNXH5BdJiXoe0k43Ry9ptK3jHAsKjlQ3jVZg=";
  };
in pkgs.symlinkJoin {
  name = "nix-binary-tarballs";
  paths = [
    (pkgs.callPackage "${nix_src}/scripts/binary-tarball.nix" {})
    (pkgs.callPackage "${nix_src}/scripts/binary-tarball.nix" {
      nix    = pkgs.pkgsCross.riscv64.nix;
      system = pkgs.pkgsCross.riscv64.nix.stdenv.system;
    })
    (pkgs.callPackage "${nix_src}/scripts/binary-tarball.nix" {
      nix    = pkgs.pkgsCross.loongarch64-linux.nix;
      system = pkgs.pkgsCross.loongarch64-linux.nix.stdenv.system;
    })
  ];
}
