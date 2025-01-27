#MC # hbac-nvim: auto close buffer
{ config, pkgs, stdenv, lib, ... }:
let
  my-hbac = {
    plugin = pkgs.vimUtils.buildVimPlugin {
      name = "hbac.nvim";
      src = pkgs.fetchFromGitHub {
        owner = "axkirillov";
        repo = "hbac.nvim";
        rev = "e2e8333aa56ef43a577ac3a2a2e87bdf2f0d4cbb";
        hash = "sha256-7+e+p+0zMHPJjpnKNkL7QQHZJGQ1DFZ6fsofcsVNXaY=";
      };
    };
    type = "lua";
    config = ''
      require("hbac").setup({
        autoclose     = true, -- set autoclose to false if you want to close manually
        threshold     = 10, -- hbac will start closing unedited buffers once that number is reached
        close_command = function(bufnr)
          vim.api.nvim_buf_delete(bufnr, {})
        end,
        close_buffers_with_windows = false, -- hbac will close buffers with associated windows if this option is `true`
        telescope = {
          -- See #telescope-configuration below
          },
      })
    '';
  };
in {
  programs.neovim = {
    plugins = [
      my-hbac
    ];
  };
}
