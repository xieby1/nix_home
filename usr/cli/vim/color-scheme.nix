#MC # 🎨My nvim color scheme
{ config, pkgs, stdenv, lib, ... }:
let
  my-color-scheme = {
    plugin = pkgs.vimPlugins.sonokai;
    config = ''
      nnoremap <leader>c :set termguicolors!<CR>
      set termguicolors

      let g:sonokai_transparent_background = 1

      let g:sonokai_colors_override = {
      \ 'black':    ['#111215', '237'],
      \ 'bg0':      ['#22232a', '235'],
      \ 'bg1':      ['#33353f', '236'],
      \ 'bg2':      ['#444754', '236'],
      \ 'bg3':      ['#555869', '237'],
      \ 'bg4':      ['#666a7e', '237'],
      \ 'grey':     ['#a5a5a6', '246'],
      \ 'grey_dim': ['#787879', '240'],
      \}

      " custom sonokai,
      " see section "How to use custom colors" of `:h sonokai.vim`
      function! s:sonokai_custom() abort
        let l:palette = sonokai#get_palette('default', {})
        call sonokai#highlight('StatusLine', l:palette.black, l:palette.fg, 'bold')
        call sonokai#highlight('StatusLineNC', l:palette.black, l:palette.grey, 'bold')
      endfunction
      augroup SonokaiCustom
        autocmd!
        autocmd ColorScheme sonokai call s:sonokai_custom()
      augroup END

      colorscheme sonokai
    '';
  };
in {
  programs.neovim = {
    plugins = [
      my-color-scheme
    ];
  };
}
