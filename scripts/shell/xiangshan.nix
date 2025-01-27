let
  name = "xiangshan";
  pkgs = import <nixpkgs> {};
in pkgs.mkShell {
  inherit name;

  buildInputs = let
    h_content = builtins.toFile "h_content" ''
      # ${pkgs.lib.toUpper "${name} usage tips"}
    '';
    _h_ = pkgs.writeShellScriptBin "h" ''
      ${pkgs.glow}/bin/glow ${h_content}
    '';
    mill_0_11_8 = (import (pkgs.fetchFromGitHub {
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "05bbf675397d5366259409139039af8077d695ce";
      sha256 = "1r26vjqmzgphfnby5lkfihz6i3y70hq84bpkwd43qjjvgxkcyki0";
    }){}).mill;
  in [
    _h_
    mill_0_11_8
  ] ++ (with pkgs; [
    espresso
    verilator

    # libs
    sqlite
    zlib
    zstd
  ]);

  shellHook = let
    circt_1_62_0 = (import (pkgs.fetchFromGitHub {
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "771b079bb84ac2395f3a24a5663ac8d1495c98d3";
      sha256 = "0l1l9ms78xd41xg768pkb6xym200zpf4zjbv4kbqbj3z7rzvhpb7";
    }){}).circt;
  in ''
    h
    export CHISEL_FIRTOOL_PATH=${circt_1_62_0}/bin/
    export NOOP_HOME=$(realpath .)
  '';
}
