#MC # vim-hexokinase: display colors
#MC
#MC ## highlight color code
#MC
#MC TLDR: vim-hexokinase isn't perfect but works.
#MC It need works in `termguicolors` mode.
#MC It is better to choose a color scheme which is visualized in gui mode.
#MC And it is very tricky to setting colors in `termguicolors` & `notermguicolors` the same, which is insane.
#MC
#MC It would be convenient, if color code can be visualised in editor, especially in web programming.
#MC I found two candidates plugins to achieve this goal,
#MC [vim-css-color](https://github.com/ap/vim-css-color),
#MC [vim-hexokinase](https://github.com/RRethy/vim-hexokinase).
#MC
#MC Vim-css-color is not compatible with tree-sitter, due to regex based highlight.
#MC See [Github Issue: Neovim tree sitter support](https://github.com/ap/vim-css-color/issues/164) for details.
#MC Vim-css-color sometimes cannot render same text color.
#MC I need to scroll my vim viewport, then it **may** render color correctly.
#MC
#MC Vim-hexokinase is good, but must depends on `termguicolors` is turned on.
#MC `termguicolors` will enable 24-bit RGB color,
#MC while originally vim uses Base16 color.
#MC The result is the color theme you familiar with will be changed.
#MC
#MC Here is the visual comparison between vim-css-color and vim-hexokinase.
#MC I copy these text as html from my vim.
#MC
#MC | vcc                                                                                | vcc tgc                                                                            | vh tgc                                                                             |
#MC |:----------------------------------------------------------------------------------:|:----------------------------------------------------------------------------------:|:----------------------------------------------------------------------------------:|
#MC | <span style="background-color:#FF0000"><font color="#EEEEEC">#ff0000</font></span> | <span style="background-color:#FF0000"><font color="#FFFFFF">#ff0000</font></span> | <span style="background-color:#FF0000"><font color="#FFFFFF">#ff0000</font></span> |
#MC | <span style="background-color:#FF0000"><font color="#EEEEEC">#ff1111</font></span> | <span style="background-color:#FF1111"><font color="#FFFFFF">#ff1111</font></span> | <span style="background-color:#FF1111"><font color="#FFFFFF">#ff1111</font></span> |
#MC | <span style="background-color:#FF0000"><font color="#EEEEEC">#ff2222</font></span> | <span style="background-color:#FF2222"><font color="#FFFFFF">#ff2222</font></span> | <span style="background-color:#FF2222"><font color="#FFFFFF">#ff2222</font></span> |
#MC | <span style="background-color:#FF0000"><font color="#EEEEEC">#ff3333</font></span> | <span style="background-color:#FF3333"><font color="#FFFFFF">#ff3333</font></span> | <span style="background-color:#FF3333"><font color="#FFFFFF">#ff3333</font></span> |
#MC | <span style="background-color:#FF5F5F"><font color="#2E3436">#ff4444</font></span> | <span style="background-color:#FF4444"><font color="#000000">#ff4444</font></span> | <span style="background-color:#FF4444"><font color="#FFFFFF">#ff4444</font></span> |
#MC | <span style="background-color:#FF5F5F"><font color="#2E3436">#ff5555</font></span> | <span style="background-color:#FF5555"><font color="#000000">#ff5555</font></span> | <span style="background-color:#FF5555"><font color="#FFFFFF">#ff5555</font></span> |
#MC | <span style="background-color:#FF5F5F"><font color="#2E3436">#ff6666</font></span> | <span style="background-color:#FF6666"><font color="#000000">#ff6666</font></span> | <span style="background-color:#FF6666"><font color="#FFFFFF">#ff6666</font></span> |
#MC | <span style="background-color:#FF8787"><font color="#2E3436">#ff7777</font></span> | <span style="background-color:#FF7777"><font color="#000000">#ff7777</font></span> | <span style="background-color:#FF7777"><font color="#FFFFFF">#ff7777</font></span> |
#MC | <span style="background-color:#FF8787"><font color="#2E3436">#ff8888</font></span> | <span style="background-color:#FF8888"><font color="#000000">#ff8888</font></span> | <span style="background-color:#FF8888"><font color="#FFFFFF">#ff8888</font></span> |
#MC | <span style="background-color:#FF8787"><font color="#2E3436">#ff9999</font></span> | <span style="background-color:#FF9999"><font color="#000000">#ff9999</font></span> | <span style="background-color:#FF9999"><font color="#FFFFFF">#ff9999</font></span> |
#MC | <span style="background-color:#FFAFAF"><font color="#2E3436">#ffaaaa</font></span> | <span style="background-color:#FFAAAA"><font color="#000000">#ffaaaa</font></span> | <span style="background-color:#FFAAAA"><font color="#000000">#ffaaaa</font></span> |
#MC | <span style="background-color:#FFAFAF"><font color="#2E3436">#ffbbbb</font></span> | <span style="background-color:#FFBBBB"><font color="#000000">#ffbbbb</font></span> | <span style="background-color:#FFBBBB"><font color="#000000">#ffbbbb</font></span> |
#MC | <span style="background-color:#FFD7D7"><font color="#2E3436">#ffcccc</font></span> | <span style="background-color:#FFCCCC"><font color="#000000">#ffcccc</font></span> | <span style="background-color:#FFCCCC"><font color="#000000">#ffcccc</font></span> |
#MC | <span style="background-color:#FFD7D7"><font color="#2E3436">#ffdddd</font></span> | <span style="background-color:#FFDDDD"><font color="#000000">#ffdddd</font></span> | <span style="background-color:#FFDDDD"><font color="#000000">#ffdddd</font></span> |
#MC | <span style="background-color:#EEEEEE"><font color="#2E3436">#ffeeee</font></span> | <span style="background-color:#FFEEEE"><font color="#000000">#ffeeee</font></span> | <span style="background-color:#FFEEEE"><font color="#000000">#ffeeee</font></span> |
#MC | <span style="background-color:#FFFFFF"><font color="#2E3436">#ffffff</font></span> | <span style="background-color:#FFFFFF"><font color="#000000">#ffffff</font></span> | <span style="background-color:#FFFFFF"><font color="#000000">#ffffff</font></span> |
#MC | <span style="background-color:#000000"><font color="#EEEEEC">#000000</font></span> | <span style="background-color:#000000"><font color="#FFFFFF">#000000</font></span> | <span style="background-color:#000000"><font color="#FFFFFF">#000000</font></span>
#MC | <span style="background-color:#121212"><font color="#EEEEEC">#111111</font></span> | <span style="background-color:#111111"><font color="#FFFFFF">#111111</font></span> | <span style="background-color:#111111"><font color="#FFFFFF">#111111</font></span>
#MC | <span style="background-color:#262626"><font color="#EEEEEC">#222222</font></span> | <span style="background-color:#222222"><font color="#FFFFFF">#222222</font></span> | <span style="background-color:#222222"><font color="#FFFFFF">#222222</font></span>
#MC | <span style="background-color:#303030"><font color="#EEEEEC">#333333</font></span> | <span style="background-color:#333333"><font color="#FFFFFF">#333333</font></span> | <span style="background-color:#333333"><font color="#FFFFFF">#333333</font></span>
#MC | <span style="background-color:#444444"><font color="#EEEEEC">#444444</font></span> | <span style="background-color:#444444"><font color="#FFFFFF">#444444</font></span> | <span style="background-color:#444444"><font color="#FFFFFF">#444444</font></span>
#MC | <span style="background-color:#585858"><font color="#EEEEEC">#555555</font></span> | <span style="background-color:#555555"><font color="#FFFFFF">#555555</font></span> | <span style="background-color:#555555"><font color="#FFFFFF">#555555</font></span>
#MC | <span style="background-color:#626262"><font color="#EEEEEC">#666666</font></span> | <span style="background-color:#666666"><font color="#FFFFFF">#666666</font></span> | <span style="background-color:#666666"><font color="#FFFFFF">#666666</font></span>
#MC | <span style="background-color:#767676"><font color="#EEEEEC">#777777</font></span> | <span style="background-color:#777777"><font color="#FFFFFF">#777777</font></span> | <span style="background-color:#777777"><font color="#FFFFFF">#777777</font></span>
#MC | <span style="background-color:#878787"><font color="#2E3436">#888888</font></span> | <span style="background-color:#888888"><font color="#000000">#888888</font></span> | <span style="background-color:#888888"><font color="#FFFFFF">#888888</font></span>
#MC | <span style="background-color:#9E9E9E"><font color="#2E3436">#999999</font></span> | <span style="background-color:#999999"><font color="#000000">#999999</font></span> | <span style="background-color:#999999"><font color="#FFFFFF">#999999</font></span>
#MC | <span style="background-color:#A8A8A8"><font color="#2E3436">#aaaaaa</font></span> | <span style="background-color:#AAAAAA"><font color="#000000">#aaaaaa</font></span> | <span style="background-color:#AAAAAA"><font color="#FFFFFF">#aaaaaa</font></span>
#MC | <span style="background-color:#BCBCBC"><font color="#2E3436">#bbbbbb</font></span> | <span style="background-color:#BBBBBB"><font color="#000000">#bbbbbb</font></span> | <span style="background-color:#BBBBBB"><font color="#000000">#bbbbbb</font></span>
#MC | <span style="background-color:#D0D0D0"><font color="#2E3436">#cccccc</font></span> | <span style="background-color:#CCCCCC"><font color="#000000">#cccccc</font></span> | <span style="background-color:#CCCCCC"><font color="#000000">#cccccc</font></span>
#MC | <span style="background-color:#DADADA"><font color="#2E3436">#dddddd</font></span> | <span style="background-color:#DDDDDD"><font color="#000000">#dddddd</font></span> | <span style="background-color:#DDDDDD"><font color="#000000">#dddddd</font></span>
#MC | <span style="background-color:#EEEEEE"><font color="#2E3436">#eeeeee</font></span> | <span style="background-color:#EEEEEE"><font color="#000000">#eeeeee</font></span> | <span style="background-color:#EEEEEE"><font color="#000000">#eeeeee</font></span>
#MC | <span style="background-color:#FFFFFF"><font color="#2E3436">#ffffff</font></span> | <span style="background-color:#FFFFFF"><font color="#000000">#ffffff</font></span> | <span style="background-color:#FFFFFF"><font color="#000000">#ffffff</font></span>
#MC
#MC Vim-css-color with out `termguicolors` cannot display color correctly (or say precisely),
#MC if you dont believe your eye, see the source code of this page.
#MC
#MC I think vim-hexokinase with a `termguicolors` toggle is a acceptable compromise.
#MC Toggle `termguicolors` by `:set termguicolors!`.
#MC I personally prefer to assign `<leader>c` to toggle `termguicolors`.
#MC
#MC ### cterm & gui
#MC
#MC TLDR: I still haven't find a elegant solution to keep `termguicolors` and `notermguicolors` visually same.
#MC
#MC neovim has 2 color schemes cterm & gui,
#MC see `:h cterm-colors` & `:h gui-colors`.
#MC Default sntax colors are different in these two schemes.
#MC For example, `:verbose highlight Comment` returns
#MC
#MC ```vim
#MC Comment        xxx ctermfg=14 guifg=#80a0ff
#MC         Last set from /nix/store/pr1pwjjsm3k45rwi3w0xh2296rpymjlz-neovim-unwrapped-0.5.1/share/nvim/runtime/syntax/syncolor.vim
#MC ```
#MC
#MC which means ctermfg uses the 14th color in ANSI colors,
#MC while guifg use a hex color code.
#MC The detailed setting is located in `${VIMRUNTIME}/syntax/syncolor.vim`.
#MC
#MC I create a new syncolor.vim based the default one,
#MC and modify the all ctermfg and guifg to same color name, like below.
#MC The colors in two schemes are still different.
#MC
#MC ```vim
#MC if !exists("syntax_cmd") || syntax_cmd == "on"
#MC   " ":syntax on" works like in Vim 5.7: set colors but keep links
#MC   command -nargs=* SynColor hi <args>
#MC   command -nargs=* SynLink hi link <args>
#MC else
#MC   if syntax_cmd == "enable"
#MC     " ":syntax enable" keeps any existing colors
#MC     command -nargs=* SynColor hi def <args>
#MC     command -nargs=* SynLink hi def link <args>
#MC   elseif syntax_cmd == "reset"
#MC     " ":syntax reset" resets all colors to the default
#MC     command -nargs=* SynColor hi <args>
#MC     command -nargs=* SynLink hi! link <args>
#MC   else
#MC     " User defined syncolor file has already set the colors.
#MC     finish
#MC   endif
#MC endif
#MC
#MC " Many terminals can only use six different colors (plus black and white).
#MC " Therefore the number of colors used is kept low. It doesn't look nice with
#MC " too many colors anyway.
#MC " Careful with "cterm=bold", it changes the color to bright for some terminals.
#MC " There are two sets of defaults: for a dark and a light background.
#MC if &background == "dark"
#MC   SynColor Comment	term=bold cterm=NONE ctermfg=Cyan ctermbg=NONE gui=NONE guifg=Cyan guibg=NONE
#MC   SynColor Constant	term=underline cterm=NONE ctermfg=Magenta ctermbg=NONE gui=NONE guifg=Magenta guibg=NONE
#MC   SynColor Special	term=bold cterm=NONE ctermfg=LightRed ctermbg=NONE gui=NONE guifg=LightRed guibg=NONE
#MC   SynColor Identifier	term=underline cterm=bold ctermfg=Cyan ctermbg=NONE gui=bold guifg=Cyan guibg=NONE
#MC   SynColor Statement	term=bold cterm=NONE ctermfg=Yellow ctermbg=NONE gui=NONE guifg=Yellow guibg=NONE
#MC   SynColor PreProc	term=underline cterm=NONE ctermfg=LightBlue ctermbg=NONE gui=NONE guifg=LightBlue guibg=NONE
#MC   SynColor Type		term=underline cterm=NONE ctermfg=LightGreen ctermbg=NONE gui=NONE guifg=LightGreen guibg=NONE
#MC   SynColor Underlined	term=underline cterm=underline ctermfg=LightBlue gui=underline guifg=LightBlue
#MC   SynColor Ignore	term=NONE cterm=NONE ctermfg=black ctermbg=NONE gui=NONE guifg=black guibg=NONE
#MC else
#MC   SynColor Comment	term=bold cterm=NONE ctermfg=DarkBlue ctermbg=NONE gui=NONE guifg=DarkBlue guibg=NONE
#MC   SynColor Constant	term=underline cterm=NONE ctermfg=DarkRed ctermbg=NONE gui=NONE guifg=DarkBlue guibg=NONE
#MC   SynColor Special	term=bold cterm=NONE ctermfg=DarkMagenta ctermbg=NONE gui=NONE guifg=DarkMagenta guibg=NONE
#MC   SynColor Identifier	term=underline cterm=NONE ctermfg=DarkCyan ctermbg=NONE gui=NONE guifg=DarkCyan guibg=NONE
#MC   SynColor Statement	term=bold cterm=NONE ctermfg=Brown ctermbg=NONE gui=bold guifg=Brown guibg=NONE
#MC   SynColor PreProc	term=underline cterm=NONE ctermfg=DarkMagenta ctermbg=NONE gui=NONE guifg=DarkMagenta guibg=NONE
#MC   SynColor Type		term=underline cterm=NONE ctermfg=DarkGreen ctermbg=NONE gui=NONE guifg=DarkGreen guibg=NONE
#MC   SynColor Underlined	term=underline cterm=underline ctermfg=DarkMagenta gui=underline guifg=DarkMagenta
#MC   SynColor Ignore	term=NONE cterm=NONE ctermfg=white ctermbg=NONE gui=NONE guifg=white guibg=NONE
#MC endif
#MC SynColor Error		term=reverse cterm=NONE ctermfg=White ctermbg=Red gui=NONE guifg=White guibg=Red
#MC SynColor Todo		term=standout cterm=NONE ctermfg=Black ctermbg=Yellow gui=NONE guifg=Black guibg=Yellow
#MC ```
#MC
#MC The Magenta is especially dazzling,
#MC and cannot change it by below tries.
#MC
#MC Refers to [Change Vim's terminal colors when termguicolors is set #2353](https://github.com/vim/vim/issues/2353),
#MC [nvim-terminal-emulator-configuration](http://neovim.io/doc/user/nvim_terminal_emulator.html#nvim-terminal-emulator-configuration),
#MC
#MC `let g:terminal_color_13 = '#AD7FA8' " Magenta` doesn't work.
#MC
#MC Finally I choose to add a color-scheme manager,
#MC and choose a theme which has both cterm & gui color scheme.
{ config, pkgs, stdenv, lib, ... }:
let
  my-vim-hexokinase = {
    plugin = pkgs.vimPlugins.vim-hexokinase;
    config = ''
      let g:Hexokinase_highlighters = ['backgroundfull']
    '';
  };
in {
  programs.neovim = {
    plugins = [
      my-vim-hexokinase
    ];
  };
}
