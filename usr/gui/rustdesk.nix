#MC # rustdesk, the remote desktop app
{ config, pkgs, stdenv, lib, ... }:
{
  home.packages = [
    #MC The new version of rustdesk is rustdesk-flutter,
    #MC which is cached in offical nix binary cache.
    pkgs.rustdesk-flutter
  ];
  #MC Auto startup rustdesk after Gnome GUI login.
  home.file.autostart_rustdesk_desktop = {
    source = "${pkgs.rustdesk-flutter}/share/applications/rustdesk.desktop";
    target = ".config/autostart/rustdesk.desktop";
  };
}
