{ config, pkgs, stdenv, lib, ... }:
let
  my-leap-nvim = {
    plugin = pkgs.vimPlugins.leap-nvim;
    type = "lua";
    config = ''
      require('leap').create_default_mappings()
    '';
  };
in {
  programs.neovim = {
    plugins = [
      my-leap-nvim
    ];
  };
}
