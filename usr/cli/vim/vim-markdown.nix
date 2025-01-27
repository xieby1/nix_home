#MC # vim-markdown: md support
#MC
#MC 我主要使用这个插件的对齐表格的功能，`:TableFormat`，超酷炫！
{ config, pkgs, stdenv, lib, ... }:
let
  my-vim-markdown = {
    plugin = pkgs.vimPlugins.vim-markdown;
    config = ''
      let g:vim_markdown_new_list_item_indent = 2
      let g:vim_markdown_no_default_key_mappings = 1
    '';
  };
in {
  programs.neovim = {
    plugins = [
      my-vim-markdown # format table
    ];
  };
}
