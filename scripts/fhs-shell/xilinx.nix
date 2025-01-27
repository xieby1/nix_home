#!/usr/bin/env -S nix-shell --keep miao
# based on https://github.com/nix-community/nix-environments
#   git commit: 40d9d98bab7750bb5a1a9a3b5bcc1c91a652f3be
{ pkgs ? import <nixpkgs> {} }:
let
  name = "xilinx-fhs";
  h_content = builtins.toFile "h_content" ''
    # ${pkgs.lib.toUpper "${name} usage"}

    **Commands**

    * Show this help: `h`
    * Start Vitis HLS IDE: `vitis_hls`
    * Start Vitis HLS REPL: `vitis_hls -i`

    **Files**

    * Vitis HLS Doc: `2022.vitis_hls.ug1399.pdf`
    * Local command doc: `Xilinx/Vitis/2022.2/doc/eng/man/`
    * TODO: `ug871-vivado-high-level-synthesis-tutorial.pdf`
    * TODO: `ug902-vivado-high-level-synthesis.pdf`

    **Examples**

    * [Vitis HLS examples](https://github.com/Xilinx/Vitis-HLS-Introductory-Examples)
    * Run an example: `vitis_hls -f run_hls.tcl`
  '';
  _h_ = pkgs.writeShellScriptBin "h" ''
    ${pkgs.glow}/bin/glow ${h_content}
  '';
in
(pkgs.buildFHSUserEnv {
  inherit name;
  targetPkgs = pkgs: with pkgs; [
    _h_

    bash
    coreutils
    zlib
    lsb-release
    stdenv.cc.cc
    ncurses5
    xorg.libXext
    xorg.libX11
    xorg.libXrender
    xorg.libXtst
    xorg.libXi
    xorg.libXft
    xorg.libxcb
    xorg.libxcb
    # common requirements
    freetype
    fontconfig
    glib
    gtk2
    gtk3
    # vitis_hls gcc needs
    glibc.dev

    # to compile some xilinx examples
    opencl-clhpp
    ocl-icd
    opencl-headers

    # from installLibs.sh
    graphviz
    (lib.hiPrio gcc)
    unzip
    nettools
  ];
  multiPkgs = null;
  profile = ''
    export LC_NUMERIC="en_US.UTF-8"
    source ~/Xilinx/Vitis_HLS/*/settings64.sh
    h
  '';
}).env
