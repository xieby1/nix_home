{ pkgs, ... }: {
  programs.neovim.plugins = [{
    plugin = pkgs.vimUtils.buildVimPlugin {
      pname = "codecompanion.nvim";
      # currently lastest
      version = "2025-1-27";
      src = pkgs.fetchFromGitHub {
        owner = "olimorris";
        repo = "codecompanion.nvim";
        rev = "f8b9dce0468708c3b280abb045927c6864a17869";
        hash = "sha256-1EMzh3TaQxj+eMLjizHwntl/6ZqTHRlxFF6IOSROnuA=";
      };
      meta.homepage = "https://github.com/olimorris/codecompanion.nvim/";
    };
    type = "lua";
    # https://codecompanion.olimorris.dev/configuration/adapters.html
    config = ''
      require("codecompanion").setup({
        adapters = {
          deepseek = function()
            return require("codecompanion.adapters").extend("deepseek", {
              env = {
                api_key = "cmd:cat ~/Gist/Vault/deepseek_api_key_nvim.txt",
              },
              schema = {
                model = {
                  default = "deepseek-chat",
                },
              },
            })
          end,
        },
        display = {
          chat = {
            diff = {
              enabled = true,
            },
          },
        },
        strategies = {
          chat = {
            adapter = "deepseek",
          },
          inline = {
            adapter = "deepseek",
          },
        },
      })
    '';
  }];
}
