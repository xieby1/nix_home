#MC # telescope-nvim
{ config, pkgs, stdenv, lib, ... }:
let
  my-telescope-nvim = {
    plugin = pkgs.vimPlugins.telescope-nvim;
    config = ''
      " search relative to file
      "" https://github.com/nvim-telescope/telescope.nvim/pull/902
      nnoremap ff <cmd>lua require('telescope.builtin').find_files({cwd=require'telescope.utils'.buffer_dir()})<cr>
      nnoremap fg <cmd>lua require('telescope.builtin').live_grep({cwd=require'telescope.utils'.buffer_dir()})<cr>
      nnoremap fF <cmd>lua require('telescope.builtin').find_files()<cr>
      nnoremap fG <cmd>lua require('telescope.builtin').live_grep()<cr>
      nnoremap fb <cmd>lua require('telescope.builtin').buffers()<cr>
      nnoremap fh <cmd>lua require('telescope.builtin').help_tags()<cr>
      nnoremap ft <cmd>lua require('telescope.builtin').treesitter()<cr>
      nnoremap fc <cmd>lua require('telescope.builtin').command_history()<cr>
      nnoremap fC <cmd>lua require('telescope.builtin').commands()<cr>
    '';
  };
  my-telescope-fzf-native-nvim = {
    plugin = pkgs.vimPlugins.telescope-fzf-native-nvim;
    type = "lua";
    config = ''
      require('telescope').setup {
        extensions = {fzf = {}},
        defaults = {
          layout_strategy = 'vertical'
        }
      }
      require('telescope').load_extension('fzf')
    '';
  };
in {
  programs.neovim = {
    plugins = [
      my-telescope-nvim
      my-telescope-fzf-native-nvim
      pkgs.vimPlugins.plenary-nvim
    ];
    extraPackages = with pkgs; [
      ripgrep
    ];
  };
}
