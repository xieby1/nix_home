#MC # nvim-metals: Scala LSP
#MC
#MC The JRE proxy need subtle configuration.
{ config, pkgs, ... }:
let
  opt = import ../../../../opt.nix;
  jre_with_proxy = pkgs.callPackage ./jre_with_proxy.nix {
    jre = pkgs.openjdk_headless;
    proxyHost = "127.0.0.1";
    proxyPort = toString opt.proxyPort;
  };
  my-nvim-metals = {
    plugin = pkgs.vimPlugins.nvim-metals;
    type = "lua";
    config = ''
      -- lspconfig.metals.setup{}
      local metals_config = require("metals").bare_config()
      metals_config.find_root_dir_max_project_nesting = 2
      metals_config.root_patterns = {
        "build.sbt",
        "build.sc",
        ".git",
      }
      metals_config.settings = {
        showImplicitArguments = true,
        excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
        serverProperties = {
          "-Dhttps.proxyHost=127.0.0.1",
          "-Dhttps.proxyPort=${toString opt.proxyPort}",
          "-Dhttp.proxyHost=127.0.0.1",
          "-Dhttp.proxyPort=${toString opt.proxyPort}",
        },
        -- see `:h metalsBinaryPath`, "Another setting for you crazy Nix kids." Hahaha!
        metalsBinaryPath = "${pkgs.metals.override {jre = jre_with_proxy;}}/bin/metals",
        javaHome = "${jre_with_proxy}",
        showImplicitArguments = true,
        showImplicitConversionsAndClasses = true,
        showInferredType = ture,
      }
      metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()
      -- Autocmd that will actually be in charging of starting the whole thing
      local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = nvim_metals_group,
        pattern = { "scala", "sbt" },
        callback = function()
          require("metals").initialize_or_attach(metals_config)
        end,
      })
    '';
  };
in {
  programs.neovim = {
    plugins = [
      my-nvim-metals
    ];
    extraPackages = [
      (pkgs.coursier.override {
        jre = jre_with_proxy;
      })
    ];

  };
  # nvim-metals proxy for bloop
  home.file.jvmopts = {
    text = ''
      -Dhttps.proxyHost=127.0.0.1
      -Dhttps.proxyPort=${toString opt.proxyPort}
      -Dhttp.proxyHost=127.0.0.1
      -Dhttp.proxyPort=${toString opt.proxyPort}
    '';
    target = ".bloop/.jvmopts";
  };
}
