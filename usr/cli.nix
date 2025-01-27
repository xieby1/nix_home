{ config, pkgs, stdenv, lib, ... }:
let
  opt = import ../opt.nix;
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
  fzf-doc = pkgs.writeScriptBin "fzf-doc" ''
    allCmds() {
      # bash alias
      compgen -A alias

      # external commands
      # https://unix.stackexchange.com/questions/94775/list-all-commands-that-a-shell-knows
      case "$PATH" in
        (*[!:]:) PATH="$PATH:" ;;
      esac
      set -f
      IFS_OLD="$IFS"
      IFS=:
      for dir in $PATH; do
        set +f
        [ -z "$dir" ] && dir="."
        for file in "$dir"/*; do
          if [ -x "$file" ] && ! [ -d "$file" ]; then
            echo "''${file##*/}"
          fi
        done
      done
      IFS="$IFS_OLD"
    }

    cd ~/Documents
    FILE=$(fzf)
    [ -z "$FILE" ] && exit

    CMD=$(allCmds | fzf)
    [ -z "$CMD" ] && exit

    case "$CMD" in
    # run gui cmd background
    o)
      # use nohup to run bash command in background and exit
      ## https://superuser.com/questions/448445/run-bash-script-in-background-and-exit-terminal
      # nohup not recognize bash alias like `o`, it's necessary to call bash
      eval nohup bash -ic '"$CMD \"$FILE\" &"'
    ;;

    # run cli cmd foreground
    *)
      # FILE name may contain space, quote FILE name
      eval "$CMD" \"$FILE\"
    ;;
    esac
  '';
  sysconfig = (
    # <...> are expression search in NIX_PATH
    if (builtins.tryEval <nixos-config>).success
    then import <nixpkgs/nixos> {}
    else import <nixpkgs/nixos> {configuration={};}
  ).config;
in
{
  imports = lib.optionals (!opt.isMinimalConfig) [
    ./cli-extra.nix
  ] ++ [ # files
    ./cli/vim
    ./cli/tmux.nix
    ./cli/clash.nix
    ./cli/tailscale.nix
    # When init searxng, it throws `ERROR:searx.engines.wikidata: Fail to initialize`
    # I have no idea, so disable it.
    # ./cli/searxng.nix
  ] ++ [{ # functions & attrs
    home.packages = [
      pkgs.fzf
      fzf-doc
    ];
    programs.bash.bashrcExtra = ''
      # FZF top-down display
      export FZF_DEFAULT_OPTS="--reverse"
    '';
  }{
    home.packages = lib.optional (!opt.isNixOnDroid) pkgs.hstr;
    programs.bash.bashrcExtra = lib.optionalString (!opt.isNixOnDroid) ''
      # HSTR configuration - add this to ~/.bashrc
      alias hh=hstr                    # hh to be alias for hstr
      export HSTR_CONFIG=hicolor       # get more colors
      shopt -s histappend              # append new history items to .bash_history
      export HISTCONTROL=ignorespace   # leading space hides commands from history
      # ensure synchronization between bash memory and history file
      export PROMPT_COMMAND="history -a;"
      # if this is interactive shell, then bind hstr to Ctrl-r (for Vi mode check doc)
      if [[ $- =~ .*i.* ]]; then bind '"\C-r": "\C-a hstr -- \C-j"'; fi
      # if this is interactive shell, then bind 'kill last command' to Ctrl-x k
      if [[ $- =~ .*i.* ]]; then bind '"\C-xk": "\C-a hstr -k \C-j"'; fi
    '';
  }{
    programs.ssh.enable = true;
    programs.ssh.includes = lib.optional (builtins.pathExists ~/Gist/Config/ssh.conf) "~/Gist/Config/ssh.conf";
    programs.bash.bashrcExtra = lib.optionalString opt.isNixOnDroid ''
      # start sshd
      if [[ -z "$(pidof sshd-start)" ]]; then
          tmux new -d -s sshd-start sshd-start
      fi
    '';
  }{
    home.packages = with pkgs; [
      gitui
      mr
      git-wip
      git-quick-stats
    ];
    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      userEmail = "xieby1@outlook.com";
      userName = "xieby1";
      extraConfig = {
        core = {
          editor = "vim";
        };
        credential.helper = "store";
      };
      aliases = {
        viz = "log --all --decorate --oneline --graph";
      };
      lfs.enable = true;
    };
    home.file.mr = {
      text = if builtins.pathExists ~/Gist/Config/mrconfig
        then builtins.readFile ~/Gist/Config/mrconfig
        else "";
      target = ".mrconfig";
    };
    # mr status not work in non-home dir
    programs.bash.shellAliases.mr = "mr -d ~";
  }{
    home.packages = [pkgs.nix-index];
    home.file.nix_index_database = {
      source = builtins.fetchurl "https://github.com/Mic92/nix-index-database/releases/latest/download/index-${builtins.currentSystem}";
      target = ".cache/nix-index/files";
    };
  }{
    #MC ## Syncthing
    services.syncthing = {
      enable = true;
      #MC 让syncthing的端口外部可访问。
      extraOptions = lib.optional opt.isCli "--gui-address=0.0.0.0:8384";
    };
    #MC 启用代理，因为有些syncthing的服务器似乎是被墙了的。
    systemd.user.services.syncthing.Service.Environment = [
      # https://docs.syncthing.net/users/proxying.html
      "http_proxy=http://127.0.0.1:${toString opt.proxyPort}"
    ];
    #MC 使用命令行浏览器browsh来实现syncthing-tui。
    home.packages = lib.optional (!opt.isMinimalConfig) (
      pkgs.writeShellScriptBin "syncthing-tui" ''
        ${pkgs.browsh}/bin/browsh --firefox.path ${pkgs.firefox}/bin/firefox http://127.0.0.1:8384
      ''
    );
  }{
    home.packages = with pkgs; [
      cachix
    ];
    home.file.cachix_dhall = {
      source = if (builtins.pathExists ~/Gist/Config/cachix.dhall)
        then ~/Gist/Config/cachix.dhall
        else builtins.toFile "empty-cachix.dhall" "";
      target = ".config/cachix/cachix.dhall";
    };
  }{
    home.packages = with pkgs; [
      universal-ctags
    ];
    home.file.exclude_ctags = {
      text = ''
        # exclude ccls generated directories
        --exclude=.ccls*
      '';
      target = ".config/ctags/exclude.ctags";
    };
  }];

  home.packages = with pkgs; [
    # tools
    parallel
    comma
    xclip
    python3Packages.qrcode
    ripgrep
    ## archive
    unar
    ## manage
    htop
    nix-tree
    ## text
    pandoc
    ## compile
    gnumake
    makefile2graph
    remake
    ## draw
    graphviz
    figlet
    nyancat
    ## manual
    tldr
    ## file system
    file
    # magika # detect file content types with deep learning
    tree
    ## network
    wget
    axel
    bind.dnsutils # nslookup
    netcat
    nload
    nmap
    nethogs
    ## x11
    xdotool

    # programming
    inotify-tools
    clang-tools
    cmake
    capstone
    scc
    ## https://stackoverflow.com/questions/40165650/how-to-list-all-files-tracked-by-git-excluding-submodules
    (writeShellScriptBin "scc-git" "${scc}/bin/scc $(git grep --cached -l '')")
    sloccount
    flamegraph
    ## python
    ( python3.withPackages ( p: with p; [
      ipython
      pydot
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
    ### docs
    stdmanpages
    man-pages
    #gccStdenv
    bear
    ## xml
    libxml2
    ## bash
    bc
    ## nix
    nixos-option
    nix-output-monitor
    ### allow non-nixos access `man configuration.nix`
    # see: nixos/modules/misc/documentation.nix
    #        nixos/doc/manual/default.nix
    sysconfig.system.build.manual.nixos-configuration-reference-manpage
    nurl
  ];

  programs.eza.enable = true;

  # bash
  programs.bash.enable = true;
  programs.bash.shellAliases.o = "xdg-open";
  programs.bash.bashrcExtra = ''
    # rewrite prompt format
    u_green="\[\033[01;32m\]"
    u_blue="\[\033[01;34m\]"
    u_white="\[\033[00m\]"
    PS1="''${debian_chroot:+($debian_chroot)}"
    if [[ $HOSTNAME =~ qemu.* ]]; then
        PS1+="(qemu)"
    fi
    if [[ -n "$IN_NIX_SHELL" ]]; then
        PS1+="(''${name}.$IN_NIX_SHELL)"
    fi
    PS1+="''${u_green}\u${lib.optionalString (!opt.isNixOnDroid) "@\\h"}''${u_white}:"
    PS1+="''${u_blue}\w''${u_white}"
    PS1+="\n''${u_green}\$''${u_white} "
    unset u_green u_blue u_white
    ## change title
    ### https://unix.stackexchange.com/questions/177572/
    PS1+="\[\e]2;\w\a\]"

    # nixos obsidian
    export NIXPKGS_ALLOW_INSECURE=1

    # source my bashrc
    if [[ -f ~/Gist/Config/bashrc ]]; then
        source ~/Gist/Config/bashrc
    fi

    # user nix config setting
    export NIX_USER_CONF_FILES=~/.config/nixpkgs/nix/nix.conf
    if [[ -e ~/.nix-profile/etc/profile.d/nix.sh ]]; then
        source ~/.nix-profile/etc/profile.d/nix.sh
    fi

    # bash-completion, inspired by
    ##  https://discourse.nixos.org/t/whats-the-nix-way-of-bash-completion-for-packages/20209/16
    # system tools completion, e.g. nix
    XDG_DATA_DIRS+=":${sysconfig.system.path}/share"
    # home tools completion
    XDG_DATA_DIRS+=":${config.home.path}/share"
    export XDG_DATA_DIRS
    . ${pkgs.bash-completion}/etc/profile.d/bash_completion.sh

    # 解决tmux在nix-on-droid上不显示emoji和中文的问题
    export LANG=C.UTF-8

    if [[ -n $(command -v eza) ]]; then
        alias ls=eza
    fi
  '' + lib.optionalString opt.isWSL2 ''
    # use the working directory of the current tab as the starting directory for a new tab
    # https://learn.microsoft.com/en-us/windows/terminal/tutorials/new-tab-same-directory#using-actions-to-duplicate-the-path
    PROMPT_COMMAND=''${PROMPT_COMMAND:+"$PROMPT_COMMAND"}'printf "\e]9;9;%s\e\\" "$(wslpath -w "$PWD")"'
  '';
  ## after direnv's bash.initExtra
  programs.bash.initExtra = lib.mkOrder 2000 ''
    # https://stackoverflow.com/questions/1862510/how-can-the-last-commands-wall-time-be-put-in-the-bash-prompt
    function timer_start {
      _timer=''${_timer:-$SECONDS}
    }
    function timer_stop {
      last_timer=$(($SECONDS - $_timer))

      _notification_threthold=10
      if [[ $last_timer -ge $_notification_threthold ]]; then
        _notification="[''${last_timer}s⏰] Job finished!"
        if [[ "$TERM" =~ tmux ]]; then
          # https://github.com/tmux/tmux/issues/846
          printf '\033Ptmux;\033\x1b]99;;%s\033\x1b\\\033\\' "$_notification"
        else
          printf '\x1b]99;;%s\x1b\\' "$_notification"
        fi
      fi
    }
    function timer_unset {
      unset _timer
    }

    trap timer_start DEBUG

    PROMPT_COMMAND="timer_stop;$PROMPT_COMMAND"
    if [[ -n "$(echo $PROMPT_COMMAND | grep -o -e ';$')" ]]; then
      PROMPT_COMMAND+="timer_unset;"
    else
      PROMPT_COMMAND+=";timer_unset;"
    fi
  '';

  home.file.gdbinit = {
    source = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/cyrus-and/gdb-dashboard/2b107b27949d13f6ef041de6eec1ad2e5f7b4cbf/.gdbinit";
      sha256 = "02rxyk8hmk7xk1pyhnc5z6a2kqyd63703rymy9rfmypn6057i4sr";
      name = "gdbinit";
    };
    target = ".gdbinit";
  };
  home.file.gdb_dashboard_init = {
    text = ''
      # gdb-dashboard init file

      # available layout modules
      #   stack registers history assembly
      #   breakpoints expressions memory
      #   source threads variables
      dashboard -layout source

      # https://en.wikipedia.org/wiki/ANSI_escape_code
      #dashboard -style prompt
      ## fg bold blue
      dashboard -style prompt_not_running "\\[\\e[1;34m\\]$\\[\\e[0m\\]"
      ## fg bold green
      dashboard -style prompt_running "\\[\\e[1;32m\\]$\\[\\e[0m\\]"
    '';
    target = ".gdbinit.d/init";
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.man.generateCaches = true;
}
