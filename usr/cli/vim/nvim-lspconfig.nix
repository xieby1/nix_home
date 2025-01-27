#MC # nvim-lspconfig
{ config, pkgs, stdenv, lib, ... }:
let
  my-nvim-lspconfig = {
    plugin = pkgs.vimPlugins.nvim-lspconfig;
    type = "lua";
    config =
    #MC ## Global mappings.
    ''
      -- See `:help vim.diagnostic.*` for documentation on any of the below functions
      vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
      vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

      -- Use LspAttach autocommand to only map the following keys
      -- after the language server attaches to the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          -- Enable completion triggered by <c-x><c-o>
          vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

          -- Buffer local mappings.
          -- See `:help vim.lsp.*` for documentation on any of the below functions
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
          vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
          vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
          vim.keymap.set('n', '<space>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, opts)
          vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
          vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, opts)
        end,
      })
    ''
    #MC ## Text
    + ''
      local paths = {
        -- vim.fn.stdpath("config") .. "/spell/ltex.dictionary.en-US.txt",
        vim.fn.expand("%:p:h") .. "/.ltexdict",
      }
      local words = {}
      for _, path in ipairs(paths) do
        local f = io.open(path)
        if f then
          for word in f:lines() do
            table.insert(words, word)
          end
        f:close()
        end
      end

      require('lspconfig').ltex.setup{
        settings = {
          ltex = {
            -- Supported languages:
            -- https://valentjn.github.io/ltex/settings.html#ltexlanguage
            -- https://valentjn.github.io/ltex/supported-languages.html#code-languages
            language = "en-US", -- "zh-CN" | "en-US",
            filetypes = { "bib", "gitcommit", "markdown", "org", "plaintex", "rst", "rnoweb", "tex", "pandoc" },
            dictionary = {
              ['en-GB'] = words,
            },
          },
        },
      }
    ''
    #MC ## C/C++
    #MC
    #MC ### Why use clangd instead of ccls?
    #MC
    #MC I encountered the problem below,
    #MC when view https://github.com/xieby1/openc910 smart_run/logical/tb/sim_main1.cpp
    #MC ```
    #MC LSP[ccls]: Error NO_RESULT_CALLBACK_FOUND: {
    #MC   error = {
    #MC     code = -32603,
    #MC     message = "failed to index /home/xieby1/Codes/openc910/smart_run/work/fputc.c"
    #MC   },
    #MC   id = 1,
    #MC   jsonrpc = "2.0"
    #MC }
    #MC ```
    #MC 
    #MC After some searching, I found
    #MC 
    #MC [GitHub: neovim: issue: lsp: NO_RESULT_CALLBACK_FOUND with ccls, rust-analyzer #15844](https://github.com/neovim/neovim/issues/15844)
    #MC 
    #MC sapphire-arches found:
    #MC 
    #MC > Something is causing the r-a LSP to send two replies with the same ID, see the attached log:
    #MC > lsp_debug.log
    #MC >
    #MC > It would be nice for the neovim LSP to handle this more gracefully (not filling my screen with garbage and taking focus), but I do think the bug is in R-A here? The problem seems to be related to editor.action.triggerParameterHints?
    #MC 
    #MC [GitHub: ccls: issue: I'm very confused about this question, it's about ccls or neovim built in LSP? #836](https://github.com/MaskRay/ccls/issues/836)
    #MC 
    #MC No one try to fix the two-replies problem in ccls.
    #MC However, nimaipatel recommanded [clangd_extensions](https://github.com/p00f/clangd_extensions.nvim).
    + ''
      require('lspconfig').clangd.setup{
        filetypes = { "c", "cc", "cpp", "c++", "objc", "objcpp", "cuda", "proto" }
      }
      require("clangd_extensions.inlay_hints").setup_autocmd()
      require("clangd_extensions.inlay_hints").set_inlay_hints()
    ''
    #MC ## Nix
    + ''
      require('lspconfig').nixd.setup{}
    ''
    #MC ## Html
    + ''
      require('lspconfig').html.setup{}
    ''
    #MC ## Python
    + ''
      require('lspconfig').pyright.setup{}
    ''
    #MC ## Lua
    + ''
      require('lspconfig').lua_ls.setup{}
    ''
    #MC ## Auto completion
    + ''
      -- Add additional capabilities supported by nvim-cmp
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Enable some language servers with the additional completion capabilities offered by nvim-cmp
      local servers = {
        'ltex',
        'clangd',
        'nixd',
        'html',
        'pyright',
        'lua_ls',
      }
      for _, lsp in ipairs(servers) do
        require('lspconfig')[lsp].setup {
          -- on_attach = my_custom_on_attach,
          capabilities = capabilities,
        }
      end
    '';
  };
#MC ## Setting up my nvim-lspconfig
in {
  programs.neovim = {
    plugins = [
      my-nvim-lspconfig
      pkgs.vimPlugins.clangd_extensions-nvim
    ];
    extraPackages = with pkgs; [
      clang-tools
      ltex-ls
      nixd
      vscode-langservers-extracted # html
      pyright
      lua-language-server
    ];
  };
}
