#MC # nvim-cmp: completion
{ config, pkgs, stdenv, lib, ... }:
let
  my-nvim-cmp = {
    plugin = pkgs.vimPlugins.nvim-cmp;
    type = "lua";
    config = ''
      local cmp = require'cmp'

      cmp.setup({
        preselect = cmp.PreselectMode.None,
        snippet = {
          -- REQUIRED - you must specify a snippet engine
          expand = function(args)
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Up
          ['<C-d>'] = cmp.mapping.scroll_docs(4), -- Down
          -- C-b (back) C-f (forward) for snippet placeholder navigation.
          ['<C-Space>'] = cmp.mapping.complete(),

          -- https://github.com/hrsh7th/nvim-cmp/issues/1753
          -- The "Safely select entries with <CR>" example from wiki does not work correctly in command mode
          ["<CR>"] = cmp.mapping({
            i = function(fallback)
              if cmp.visible() and cmp.get_active_entry() then
                cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
              else
                fallback()
              end
            end,
            s = cmp.mapping.confirm({ select = true }),
            c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
          }),

          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({{
          name = 'nvim_lsp',
        }}, {{
          name = 'luasnip',
        }}, {{
          name = 'buffer',
          option = {
            -- completion using words from visible buffers
            get_bufnrs = function()
              local bufs = {}
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                bufs[vim.api.nvim_win_get_buf(win)] = true
              end
              return vim.tbl_keys(bufs)
            end
          },
        }}, {{
          name = 'path',
    '' + pkgs.lib.optionalString (builtins.currentSystem=="x86_64-linux") ''
        }}, {{
          name = 'cmp_tabnine',
    '' + ''
        }})
      })
    '';
  };
  my-cmp-tabnine = {
    plugin = pkgs.vimPlugins.cmp-tabnine;
    type = "lua";
    config = ''
      local tabnine = require('cmp_tabnine.config')

      tabnine:setup({
        max_lines = 1000,
        max_num_results = 20,
        sort = true,
        run_on_every_keystroke = true,
        snippet_placeholder = '..',
        ignored_file_types = {
          -- default is not to ignore
          -- uncomment to ignore in lua:
          -- lua = true
        },
        show_prediction_strength = false
      })
    '';
  };
in {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      my-nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      luasnip
      cmp_luasnip
    ] ++ pkgs.lib.optional (builtins.currentSystem == "x86_64-linux") my-cmp-tabnine;
  };
}
