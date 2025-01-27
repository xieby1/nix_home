#MC # home.nix
#MC
#MC `home.nix`是home-manager的入口配置文件，它导入了3个nix文件：
#MC
#MC * [`./opt.nix`](./opt.nix.md)：我定义的全局变量
#MC * [`./usr/cli.nix`](./usr/cli.nix.md)：我的所有CLI程序的配置
#MC * [`./usr/gui.nix`](./usr/gui.nix.md)：我的所有GUI程序的配置
#MC
#MC 因为部分系统不需要GUI程序，比如安卓手机nix-on-droid或是树莓派等。
#MC 我利用环境变量`DISPLAY`用于判断是否导入GUI程序的配置。

{ config, pkgs, stdenv, lib, ... }:
let
  opt = import ./opt.nix;
in {
  imports = [
    ./usr/modules/cachix.nix
    ./usr/cli.nix
  ] ++ lib.optionals opt.isGui [
    ./usr/gui.nix
  ];

  home.stateVersion = "19.09";
  programs.home-manager.enable = true;
}
