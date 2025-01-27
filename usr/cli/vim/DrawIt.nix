#MC # DrawIt: ascii art drawing
{ config, pkgs, stdenv, lib, ... }:
let
  DrawIt = pkgs.vimUtils.buildVimPlugin {
    name = "DrawIt";
    src = pkgs.fetchFromGitHub {
      owner = "vim-scripts";
      repo = "DrawIt";
      rev = "master"; # I believe it wont update ^_*, so its safe
      sha256 = "0yn985pj8dn0bzalwfc8ssx62m01307ic1ypymil311m4gzlfy60";
    };
  };
in {
  programs.neovim = {
    plugins = [
      DrawIt
    ];
  };
}
