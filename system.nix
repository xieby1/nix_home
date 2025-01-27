#MC # system.nix
#MC
#MC 本文件`system.nix`存放喆我的NixOS的配置。
#MC NixOS的配置通过命令`sudo nixos-rebuid switch`生效。
#MC 因为NixOS的配置入口是`/etc/nixos/configuration.nix`，
#MC 所以需要在`/etc/nixos/configuration.nix`中import本文件，例如
#MC
#MC ```nix
#MC # /etc/nixos/configuration.nix:
#MC { config, pkgs, ... }: {
#MC   imports = [
#MC     ./hardware-configuration.nix
#MC     # import my system.nix here!
#MC     /home/xieby1/.config/nixpkgs/system.nix
#MC   ];
#MC   # other configs ...
#MC }
#MC ```
#MC
#MC NixOS配置可以使用的参数可参考configuration.nix的manpage，即`man configuration.nix`。
#MC 下面是我的NixOS的配置源码及注解：

# add this file to /etc/nixos/configuration.nix: imports
{ config, pkgs, ... }:

{
  #MC 让NixOS的nixpkgs使用和home-manager的nixpkgs采用相同的nixpkgs config
  nixpkgs.config = import ./config.nix;

  #MC 导入我的NixOS的CLI和GUI配置，
  #MC 详细内容见文档[./sys/cli.nix](./sys/cli.nix.md)和[./sys/gui.nix](./sys/gui.nix.md)。
  imports = [
    ./sys/modules/cachix.nix
    ./sys/cli.nix
    ./sys/gui.nix
  ];

  #MC Nix binary cache的地址。
  #MC 越靠前优先级越高。
  #MC 由于cache.nixos.org需要梯子，
  #MC 这里使用了清华Tuna提供的Nix binary cache镜像来加速。
  nix.settings.substituters = [
    "https://cache.nixos.org/"
    "https://xieby1.cachix.org"
  ];

  #MC 设置时区。
  time.timeZone = "Asia/Shanghai";
  time.hardwareClockInLocalTime = true;

  #MC 设置Linux账户信息。
  users.mutableUsers = false;
  #MC 当然GitHub上当然不能明文存储密码，这里使用hash过的密码。
  #MC 可以使用命令行工具`mkpasswd`来生成hash过的密码。
  #MC 给`root`用户设置hash过的密码。
  users.users.root.hashedPassword = "$6$wRBpbr4zSTA/nh$XI/KUASw3mELIqyAxN1hUTWizz9ZBzPhP2u4HNDCA49h4KOWkZsyuiextyXkUti7jYsUHE9fTiRjGAoxBg0Gq/";
  users.users.xieby1 = {
    isNormalUser = true;
    createHome = true;
    #MC 同上，给`xieby1`用户设置hash过的密码。
    hashedPassword = "$6$Y4KJxhdaJTT$RSolbCpaUKK2UW1cdnuH.8n1Ky9p0Lnx0MP36BxGX9Q2AeVMjCp.bZOsZ11w689je/785TFRQoVgicMiOfA9B.";
    #MC 给用户`xieby1`启用sudo。
    extraGroups = [ "wheel" ];
    #MC ssh授权的公钥。这样设置后，我的所有的NixOS都相当于“自动授权”了。
    #MC 我的`/home/xieby1/Gist/`文件夹存放着一些不方便放入Git仓库的文件，比如二进制文件，或是隐私文件。
    #MC 该文件由[syncthing](https://github.com/syncthing/syncthing)进行多设备同步。
    #MC 简单的说，我的备份理念是“git备份配置，syncthing备份数据”。
    #MC “配置”即指这个[nix_config仓库](https://github.com/xieby1/nix_config)，“数据”指`~/Gist/`、`~/Documents/`等文件夹。
    #MC 有了这些备份就能轻松还原/复现我的整个工作环境。
    #MC TODO：单独专门介绍我的备份理念。
    openssh.authorizedKeys.keyFiles = [] ++ (
      if builtins.pathExists /home/xieby1/Gist/Vault/y50_70.pub
      then [/home/xieby1/Gist/Vault/y50_70.pub]
      else []
    ) ++ (
      if builtins.pathExists /home/xieby1/Gist/Vault/yoga14s.pub
      then [/home/xieby1/Gist/Vault/yoga14s.pub]
      else []
    );
  };

  #MC 让TTY自动登录我的账户，这样就可以自动启动用户级（user）的systemd服务了。
  #MC 这样就可以在<span style="color:teal">**非NixOS**</span>中（比如Ubuntu服务器、WSL2、Debian树莓派等）
  #MC 自动拉起systemd<span style="color:teal">**用户**</span>服务（比如syncthing、clash、tailscale等）。
  services.getty.autologinUser = "xieby1";
  #MC 有关systemd用户服务的配置，详细可见参考：
  #MC
  #MC * home-manager配置的manpage的services词条，
  #MC   比如`man home-configuration.nix`搜索`services.syncthing`
  #MC * 我的syncthing配置[./usr/cli.nix: syncthing](./usr/cli.nix.md#syncthing)
  #MC * 我的clash配置[./usr/cli/clash.nix](./usr/cli/clash.nix.md)
  #MC * 我的tailscale配置[./usr/cli/tailscale.nix](./usr/cli/tailscale.nix.md)
}
