#!/usr/bin/env -S nix-shell --keep miao
{pkgs ? import <nixpkgs> {}}:
let
  name = "ucasproposal";
  myTexlive = pkgs.texlive.combine {
    inherit (pkgs.texlive)
    scheme-basic

    xetex
    ctex
    checkcites

    # sty
    newtx
    xstring
    realscripts
    jknapltx
    mathalpha
    caption
    placeins
    enumitem
    listings
    algpseudocodex
    algorithms
    algorithmicx
    chemfig
    mhchem
    float

    # tex
    simplekv

    rsfs
    ;
  };
  myPython = pkgs.python3.withPackages (p: with p; [
    ipython
    matplotlib
    pandas
    numpy
    openpyxl
  ]);
in
pkgs.mkShell {
  inherit name;
  packages = with pkgs; [
    myTexlive
    myPython
    librsvg
  ];
  shellHook = ''
    # env
    export PYTHONPATH=${myPython}/${myPython.sitePackages}
    export debian_chroot=${name}
  '';
}
