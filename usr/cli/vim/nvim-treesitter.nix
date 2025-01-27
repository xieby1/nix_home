#MC # nvim-treesitter: languages parsing
{ config, pkgs, stdenv, lib, ... }:
let
  my-nvim-treesitter = {
    # Available languages see:
    #   https://github.com/nvim-treesitter/nvim-treesitter
    # see `pkgs.tree-sitter.builtGrammars.`
    # with `tree-sitter-` prefix and `-grammar` suffix removed
    plugin = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: with p; [
      c
      cpp
      python
      markdown
      lua
    ]);
    type = "lua";
    config = ''
      require 'nvim-treesitter.configs'.setup {
        -- TODO: https://github.com/NixOS/nixpkgs/issues/189838
        -- ensure_installed = {"c", "cpp", "python", "markdown"},
        ensure_installed = {},
        sync_install = false,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
          disable = {
            "nix",
          },
        },
      }
    '';
  };
in {
  programs.neovim = {
    plugins = [
      my-nvim-treesitter
    ];
  };
}
