#!/usr/bin/env -S nix-shell --keep miao
{ pkgsX86 ? import <nixpkgs> {
  localSystem.system="aarch64-linux";
  crossSystem="aarch64-linux";
} }:
pkgsX86.v8
