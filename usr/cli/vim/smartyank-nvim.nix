#MC # smartyank-nvim: smart yank to clipboard
{ config, pkgs, stdenv, lib, ... }:
let
  my-smartyank-nvim = {
    plugin = pkgs.vimPlugins.smartyank-nvim;
    type = "lua";
    config = ''
      require('smartyank').setup {
        highlight = {
          enabled = false, -- not enable highlight yanked text
        },
        validate_yank = function() return vim.v.operator == '"+y' end,
      }
    '';
  };
in {
  programs.neovim = {
    plugins = [
      my-smartyank-nvim
    ];
  };
}
