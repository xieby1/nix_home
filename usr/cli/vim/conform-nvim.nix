#MC # conform-nvim: formatter
#MC
#MC TODO: replace my conform-nvim with nixpkgs's one.
{ config, pkgs, stdenv, lib, ... }:
let
  my-conform-nvim = let
    nvim_doc_tools = pkgs.fetchFromGitHub {
      owner = "stevearc";
      repo = "nvim_doc_tools";
      rev = "2fe4503c704ac816efdbbbf70d0c070ed3052bba";
      sha256 = "sha256-PtUMBHB+1IV8Q2L6pYKKvx7bliq63Z+2v8IDC5mvAeo=";
    };
    nvim-typecheck-action = pkgs.fetchFromGitHub {
      owner = "stevearc";
      repo = "nvim-typecheck-action";
      rev = "0a5ddc13b800c50bac699edd443f494a089824cd";
      sha256 = "sha256-Mzzt2A0WCeaeIDiCWgHii+RUQNlQssPxK5/LVaEgpbU=";
    };
    neodev_nvim = pkgs.fetchFromGitHub {
      owner = "folke";
      repo = "neodev.nvim";
      rev = "627b5b543f4df551fcddb99c17a8e260c453400d";
      sha256 = "sha256-S8/dUOcVPUeh54ZTELql/H5nW3DghpCtWzyxaPjZbCw=";
    };
  in {
    plugin = pkgs.vimUtils.buildVimPlugin {
      name = "conform.nvim";
      src = pkgs.fetchFromGitHub {
        owner = "stevearc";
        repo = "conform.nvim";
        rev = "a36c68d2cd551e49883ddb2492c178d915567f58";
        sha256 = "sha256-aul/6sQZMljF3nc+WrRhVEObytu4wkoVyTM5HognK7E=";
      };
      buildInputs = with pkgs; [
        python3Packages.pyparsing
        python3
        luajitPackages.luacheck
        stylua
        git
        lua-language-server
      ];
      preBuild = ''
        sed -i 's/all: doc lint test/all: doc/g' Makefile

        mkdir -p scripts/nvim_doc_tools
        cp -r ${nvim_doc_tools}/* scripts/nvim_doc_tools/
        # disable ShaDa
        sed -i 's/nvim --headless/nvim --headless -i NONE/' scripts/nvim_doc_tools/util.py

        mkdir -p scripts/nvim-typecheck-action
        cp -r ${nvim-typecheck-action}/* scripts/nvim-typecheck-action/
        patchShebangs scripts/nvim-typecheck-action/

        mkdir -p scripts/nvim-typecheck-action/libs/neodev.nvim
        cp -r ${neodev_nvim}/* scripts/nvim-typecheck-action/libs/neodev.nvim/
      '';
    };
    type = "lua";
    config = ''
      require("conform").setup({
        formatters_by_ft = {
          nix = { "nixfmt" },
          c = { "clang_format" },
          cpp = { "clang_format" },
        },
      })

      -- refer to https://github.com/stevearc/conform.nvim/blob/master/doc/recipes.md#format-command
      vim.api.nvim_create_user_command("TrimWhitespace", function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
          }
        end
        require("conform").format({ formatters = {"trim_whitespace"}, range = range })
      end, { range = true })
      vim.keymap.set({'n','v'}, '<leader>f', ':TrimWhitespace<CR>')

      vim.api.nvim_create_user_command("Format", function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
          }
        end
        require("conform").format({ async = true, lsp_fallback = true, range = range })
      end, { range = true })
      vim.keymap.set({'n','v'}, '<leader>F', ':Format<CR>')
    '';
  };
in {
  programs.neovim = {
    plugins = [
      my-conform-nvim
    ];
    extraPackages = with pkgs; [
      nixfmt-rfc-style
      clang-tools
    ];
  };
}
