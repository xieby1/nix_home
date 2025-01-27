#MC # vista-vim: lsp symbols
{ config, pkgs, stdenv, lib, ... }:
let
  my-vista-vim = {
    plugin = pkgs.vimPlugins.vista-vim;
    config = ''
      let g:vista_default_executive = 'nvim_lsp'
    '';
  };
in {
  programs.neovim = {
    plugins = [
      my-vista-vim
    ];
  };
}
