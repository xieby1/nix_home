#MC # nvim-config-local: load local vim config
# TODO: use native neovim local local config ability.
{ config, pkgs, stdenv, lib, ... }:
let
  my-nvim-config-local = {
    plugin = pkgs.vimUtils.buildVimPlugin {
      name = "nvim-config-local";
      src = pkgs.fetchFromGitHub {
        owner = "klen";
        repo = "nvim-config-local";
        rev = "af59d6344e555917209f7304709bbff7cea9b5cc";
        sha256 = "1wg6g4rqpj12sjj0g1qxqgcpkzr7x82lk90lf6qczim97r3lj9hy";
      };
    };
    config = ''
      lua << EOF
      require('config-local').setup {
        lookup_parents = true,
        silent = true,
      }
      EOF
      augroup config-local
        autocmd BufEnter * nested lua require'config-local'.source()
      augroup END
    '';
  };
in {
  programs.neovim = {
    plugins = [
      my-nvim-config-local
    ];
  };
}
