let
  name = "riscv-tests";
  pkgs = import <nixpkgs> {};
  h_content = builtins.toFile "h_content" ''
    # ${pkgs.lib.toUpper "${name} compiling tips"}

    * `git submodule update --init --recursive`
    * `autoconf`
    * `./configure`
    * `make -j`
  '';
  _h_ = pkgs.writeShellScriptBin "h" ''
    ${pkgs.glow}/bin/glow ${h_content}
  '';
in pkgs.mkShell {
  inherit name;
  packages = with pkgs; [
    autoconf
    pkgsCross.riscv64-embedded.stdenv.cc

    _h_
  ];
  shellHook = ''
    export RISCV_PREFIX=${pkgs.pkgsCross.riscv64-embedded.stdenv.cc}/bin/riscv64-none-elf-
    h
  '';
}
