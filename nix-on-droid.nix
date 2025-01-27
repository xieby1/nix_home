#MC # nix-on-droid.nix
#MC
#MC `nix-on-droid.nix`是安卓nix-on-droid的入口配置文件。
#MC 因为原生termux并不能直接运行nix，
#MC 所以nix-on-droid的作者基于termux使用proot搞出来一个能运行nix的termux分支。
#MC
#MC nix-on-droid并未自带很多常用linux命令行工具，
#MC 因此`nix-on-droid.nix`主要负责配置那些在linux常用的，但nix-on-droid没有默认提供的命令行工具。
#MC 其他命令行工具的配置则复用home-manager的配置[`./home.nix`](./home.nix.md)。
#MC 下面是我的带注解的`nix-on-droid.nix`代码。

{ pkgs, config, ... }:

{
  #MC 添加`sshd-start`命令，用于在安卓上启动sshd服务。
  #MC 通常安卓上是没有root权限的，无法写/etc/目录的文件，
  #MC 因此将ssh的tmp目录和配置目录设定到home下面。
  #MC 这部分内容参考[nix-on-droid wiki: SSH access](https://github.com/t184256/nix-on-droid/wiki/SSH-access)
  imports = [(let
    sshdTmpDirectory = "${config.user.home}/sshd-tmp";
    sshdDirectory = "${config.user.home}/sshd";
    pathToPubKey = "${config.user.home}/.ssh/id_rsa.pub";
    port = 8022;
    sshd-start = pkgs.writeScriptBin "sshd-start" ''
      #!${pkgs.runtimeShell}

      echo "Starting sshd in non-daemonized way on port ${toString port}"
      ${pkgs.openssh}/bin/sshd -f "${sshdDirectory}/sshd_config" -D
    '';
  in {
    environment.packages = with pkgs; [
      sshd-start
    ];
    build.activation.sshd = ''
      $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${config.user.home}/.ssh"
      $DRY_RUN_CMD cat ${pathToPubKey} > "${config.user.home}/.ssh/authorized_keys"

      if [[ ! -d "${sshdDirectory}" ]]; then
        $DRY_RUN_CMD rm $VERBOSE_ARG --recursive --force "${sshdTmpDirectory}"
        $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${sshdTmpDirectory}"

        $VERBOSE_ECHO "Generating host keys..."
        $DRY_RUN_CMD ${pkgs.openssh}/bin/ssh-keygen -t rsa -b 4096 -f "${sshdTmpDirectory}/ssh_host_rsa_key" -N ""

        $VERBOSE_ECHO "Writing sshd_config..."
        $DRY_RUN_CMD echo -e "HostKey ${sshdDirectory}/ssh_host_rsa_key\nPort ${toString port}\n" > "${sshdTmpDirectory}/sshd_config"

        $DRY_RUN_CMD mv $VERBOSE_ARG "${sshdTmpDirectory}" "${sshdDirectory}"
      fi
    '';
  }) ({
  #MC 自动配置termux。
    build.activation.termux = ''
      DIR=${config.user.home}/.termux
      mkdir -p $DIR
      symlink() {
        if [[ -e $1 && ! -e $2 ]]; then
          #echo "ln -s $1 $2"
          ln -s $1 $2
        fi
      }
      SRC=${config.user.home}/Gist/Config/termux.properties
      DST=$DIR/termux.properties
      symlink $SRC $DST
      SRC=${config.user.home}/Gist/Config/colors.properties
      DST=$DIR/colors.properties
      symlink $SRC $DST
    '';
  })];

  #MC 下面是非常直观的软件安装。
  # Simply install just the packages
  environment.packages = with pkgs; [
    # User-facing stuff that you really really want to have
    vim  # or some other editor, e.g. nano or neovim
    # Some common stuff that people expect to have
    diffutils
    findutils
    utillinux
    tzdata
    hostname
    man
    gnugrep
    gnupg
    gnused
    gnutar
    bzip2
    gzip
    xz
    zip
    unzip
    gawk
    openssh
    nettools
    (lib.setPrio # make bintools less prior
      (busybox.meta.priority + 10)
      busybox
    )
  ];

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "21.11";

  #MC 导入home-manager的配置文件[./home.nix](./home.nix)的配置。
  #MC 如此操作，所有home-manager的软件和配置都能nix-on-droid中复用。
  home-manager.config = import ./home.nix;
}
