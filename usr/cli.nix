{ config, pkgs, stdenv, lib, ... }:
let
  mytailscale = let
    mytailscale-wrapper = {
      suffix, port
    }: [
      (pkgs.writeShellScriptBin "tailscale-${suffix}" ''
        tailscale --socket /tmp/tailscale-${suffix}.sock $@
      '')
      (let
        stateDir = "${config.home.homeDirectory}/.local/share/tailscale-${suffix}";
      in pkgs.writeShellScriptBin "tailscaled-${suffix}" ''
        TS_LOGS_DIR="${stateDir}" \
          ${pkgs.tailscale}/bin/tailscaled \
          --tun userspace-networking \
          --outbound-http-proxy-listen=localhost:${port} \
          --socket=/tmp/tailscale-${suffix}.sock \
          --state=${stateDir}/tailscaled.state \
          --statedir=${stateDir} \
          $@
      '')
    ];
  in pkgs.symlinkJoin {
    name = "mytailscale";
    paths = [pkgs.tailscale]
      ++ (mytailscale-wrapper {suffix="headscale"; port="1055";})
      ++ (mytailscale-wrapper {suffix="official"; port="1056";});
  };
  git-wip = builtins.derivation {
    name = "git-wip";
    system = builtins.currentSystem;
    src = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/bartman/git-wip/1c095e93539261370ae811ebf47b8d3fe9166869/git-wip";
      sha256 = "00gq5bwwhjy68ig26a62307pww2i81y3zcx9yqr8fa36fsqaw37h";
    };
    builder = pkgs.writeShellScript "git-wip-builder" ''
      source ${pkgs.stdenv}/setup
      mkdir -p $out/bin
      dst=$out/bin/git-wip
      cp $src $dst
      chmod +w $dst
      sed -i 's/#!\/bin\/bash/#!\/usr\/bin\/env bash/g' $dst
      chmod -w $dst
      chmod a+x $dst
    '';
  };
  isSys = (builtins.tryEval <nixos-config>).success;
  dummySys = import <nixpkgs/nixos> {configuration={};};
in
{
  imports = [
    {
      home.packages = [pkgs.fzf];
      programs.bash.bashrcExtra = ''
        # FZF top-down display
        export FZF_DEFAULT_OPTS="--reverse"
      '';
    }
    ./cli/vim.nix
    ./cli/tcl.nix
  ];

  home.packages = with pkgs; [
    # tools
    parallel
    comma
    nix-index
    xclip
    ## repo
    gitui
    mr
    ## archive
    unar
    ## manage
    htop
    tmux
    nix-tree
    ## text
    pandoc
    mdbook
    pdftk
    ## compile
    gnumake
    makefile2graph
    remake
    ## draw
    graphviz
    gnuclad
    imagemagick
    figlet
    ## manual
    tldr
    ## file system
    tree
    file
    ranger
    ## network
    frp
    wget
    clash
    lsof
    bind.dnsutils # nslookup
    mytailscale
    netcat
    nload
    nmap
    ## x11
    xdotool

    # programming
    universal-ctags
    cscope
    clang-tools
    cmake
    capstone
    scc
    sloccount
    linuxPackages.perf
    flamegraph
    git-wip
    ## python
    ( python3.withPackages ( p: with p; [
      ipython
    ]))
    ## c
    (lib.setPrio # make bintools less prior
      (bintools-unwrapped.meta.priority + 1)
      bintools-unwrapped
    )
    (if builtins.currentSystem == "x86_64-linux"
      then gcc_multi
      else gcc
    )
    gdb
    cling # c/cpp repl
    ### docs
    stdmanpages
    man-pages
    #gccStdenv
    bear
    ## xml
    libxml2
    ## bash
    bc
  ] ++ (if builtins.currentSystem == "x86_64-linux"
      then [hstr] else []
  ) ++ [
    ## javascript
    nodePackages.typescript
    ### node
    nodejs
    nodePackages.node2nix
    ## java
    openjdk
    ## nix
    rnix-lsp
    nixos-option

    # runXonY
    debootstrap
    qemu
  ]
  ### allow non-nixos access `man configuration.nix`
  ++ (pkgs.lib.optional (!isSys) dummySys.config.system.build.manual.manpages);

  # git
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    userEmail = "xieby1@outlook.com";
    userName = "xieby1";
    extraConfig = {
      core = {
        editor = "vim";
      };
    };
    aliases = {
      viz = "log --all --decorate --oneline --graph";
    };
  };

  # mr
  home.file.mr =
    if builtins.pathExists ~/Gist/Config/mrconfig
    then
    {
      source = ~/Gist/Config/mrconfig;
      target = ".mrconfig";
    }
    else
    {
      text = "";
      target = ".mrconfig";
    };

  # bash
  programs.bash.enable = true;
  programs.bash.shellAliases = {
    view = "nvim -R";
    mr = "mr -d ~"; # mr status not work in non-home dir
  };
  programs.bash.bashrcExtra = builtins.readFile ./cli/bashrc
    # inspired by
    ##  https://discourse.nixos.org/t/whats-the-nix-way-of-bash-completion-for-packages/20209/16
    + pkgs.lib.optionalString (!isSys) ''
      # system tools completion, e.g. nix
      XDG_DATA_DIRS+=":${dummySys.config.system.path}/share"
      # home tools completion
      XDG_DATA_DIRS+=":${config.home.path}/share"
      export XDG_DATA_DIRS
      . ${pkgs.bash-completion}/etc/profile.d/bash_completion.sh
    '';

  # tmux
  home.file.tmux = {
    source = ./cli/tmux.conf;
    target = ".tmux.conf";
  };

  programs.ssh.enable = true;
  programs.ssh.extraConfig =
    if builtins.pathExists ~/Gist/Config/ssh.conf
    then
      builtins.readFile ~/Gist/Config/ssh.conf
    else
      "";

  systemd.user.services.clash = {
    Unit = {
      Description = "Auto start clash";
      After = ["network.target"];
    };
    Install = {
      WantedBy = ["default.target"];
    };
    Service = {
      ExecStart = "${pkgs.clash.outPath}/bin/clash -d ${config.home.homeDirectory}/Gist/clash";
    };
  };

  home.file.gdbinit = {
    source = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/cyrus-and/gdb-dashboard/2b107b27949d13f6ef041de6eec1ad2e5f7b4cbf/.gdbinit";
      sha256 = "02rxyk8hmk7xk1pyhnc5z6a2kqyd63703rymy9rfmypn6057i4sr";
      name = "gdbinit";
    };
    target = ".gdbinit";
  };
  home.file.gdb_dashboard_init = {
    source = ./cli/gdbinit;
    target = ".gdbinit.d/init";
  };

  home.file.nix_index_database = {
    source = pkgs.fetchurl {
      url = "https://github.com/Mic92/nix-index-database/releases/download/2022-06-05/index-x86_64-linux";
      sha256 = "0zz47as14lsj930jm9gplsngxr5d92fsg7fw1qxk0lgq7phawj5m";
    };
    target = ".cache/nix-index/files";
  };

  home.file.ranger_conf = {
    source = ./cli/ranger.conf;
    target = ".config/ranger/rc.conf";
  };

  # for my headtail
  systemd.user.services.tailscaled-headscale = {
    Unit = {
      Description = "Auto start tailscaled-headscale userspace network";
      After = ["clash.service"];
    };
    Install = {
      WantedBy = ["default.target"];
    };
    Service = {
      Environment = [
        "HTTPS_PROXY=http://127.0.0.1:8889"
        "HTTP_PROXY=http://127.0.0.1:8889"
        "https_proxy=http://127.0.0.1:8889"
        "http_proxy=http://127.0.0.1:8889"
      ];
      ExecStart = "${mytailscale}/bin/tailscaled-headscale";
    };
  };
  # for official tailscale
  systemd.user.services.tailscaled-official = {
    Unit = {
      Description = "Auto start tailscaled-official userspace network";
      After = ["clash.service"];
    };
    Install = {
      WantedBy = ["default.target"];
    };
    Service = {
      Environment = [
        "HTTPS_PROXY=http://127.0.0.1:8889"
        "HTTP_PROXY=http://127.0.0.1:8889"
        "https_proxy=http://127.0.0.1:8889"
        "http_proxy=http://127.0.0.1:8889"
      ];
      ExecStart = "${mytailscale}/bin/tailscaled-official";
    };
  };

  # systemd.user.services.onedrive = {
  #   Unit = {
  #     Description = "OneDrive Free Client";
  #     Documentation = "https://github.com/abraunegg/onedrive";
  #     After = "network-online.target";
  #     Wants = "network-online.target";
  #   };
  #   Service = {
  #     Environment = ["HTTP_PROXY=http://127.0.0.1:8889" "HTTPS_PROXY=http://127.0.0.1:8889"];
  #     ExecStart = "${pkgs.onedrive}/bin/onedrive --monitor";
  #     Restart = "on-failure";
  #   };
  #   Install = {
  #     WantedBy = [ "default.target" ];
  #   };
  # };
  # home.file.onedrive = {
  #   source = ./cli/onedrive.config;
  #   target = ".config/onedrive/config";
  # };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  services.syncthing = let
    isCli = (builtins.getEnv "DISPLAY")=="";
  in {
    enable = true;
    extraOptions = if isCli
      then ["--gui-address=0.0.0.0:8384"]
      else [];
  };
}
