#MC # vim-floaterm: floating terminal
{ config, pkgs, stdenv, lib, ... }:
let
  my-vim-floaterm = {
    plugin = pkgs.vimPlugins.vim-floaterm;
    config = ''
      nmap <Leader>t :FloatermNew --cwd=<buffer><CR>
      " let g:floaterm_keymap_new = '<Leader>t'
      let g:floaterm_width = 0.8
      let g:floaterm_height = 0.8
      " Set floaterm window's background
      hi Floaterm guibg=black
    '';
  };
in {
  programs.neovim = {
    plugins = [
      my-vim-floaterm
    ];
  };
}
