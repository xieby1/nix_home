#MC # vim-mark: multi-color highlight
{ config, pkgs, stdenv, lib, ... }:
let
  vim-ingo-library = pkgs.vimUtils.buildVimPlugin {
    name = "vim-ingo-library";
    src = pkgs.fetchFromGitHub {
      owner = "inkarkat";
      repo = "vim-ingo-library";
      rev = "8ea0e934d725a0339f16375f248fbf1235ced5f6";
      sha256 = "1rabyhayxswwh85lp4rzi2w1x1zbp5j0v025vsknzbqi0lqy32nk";
    };
  };
  my-vim-mark = {
    plugin = pkgs.vimUtils.buildVimPlugin {
      name = "vim-mark";
      src = pkgs.fetchFromGitHub {
        owner = "inkarkat";
        repo = "vim-mark";
        rev = "7f90d80d0d7a0b3696f4dfa0f8639bba4906d037";
        sha256 = "0n8r0ks58ixqv7y1afliabiqwi55nxsslwls7hni4583w1v1bbly";
      };
    };
    config = ''
      " clear highlight created by vim-mark
      nnoremap <leader><F3> :MarkClear<CR>
      " show all marks
      nnoremap <leader>M :Marks<CR>
    '';
  };
in {
  programs.neovim = {
    plugins = [
      my-vim-mark
      vim-ingo-library
    ];
  };
}
