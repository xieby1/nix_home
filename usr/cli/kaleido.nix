{ buildPythonPackage
, lib
, nss
, nspr
, expat
, fetchPypi
}:
let
  rpath = lib.makeLibraryPath [
    nss
    nspr
    expat
  ];
in buildPythonPackage rec {
  pname = "kaleido";
  version = "0.2.1";
  format = "wheel";
  src = fetchPypi {
    inherit pname version format;
    platform = "manylinux1_x86_64";
    hash = "sha256-qiHPG/HHj4+lCp99ReEAPDh709b+CnZ8+780S5W9w6g=";
  };
  doCheck = false;
  postFixup = ''
    for file in $(find $out -type f \( -perm /0111 -o -name \*.so\* \) ); do
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$file" || true
      patchelf --set-rpath ${rpath}:$out/lib/x86_64-linux-gnu $file || true
    done
    sed -i 's,#!/bin/bash,#!/usr/bin/env bash,' $out/lib/python3.11/site-packages/kaleido/executable/kaleido
  '';
}
