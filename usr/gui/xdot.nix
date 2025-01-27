#MC # xdot, the dot (graphviz) viewer
{ config, pkgs, stdenv, lib, ... }:
let
  #MC Add a xdot.desktop for my xdot.
  myxdot = pkgs.symlinkJoin {
    name = "myxdot";
    paths = [
      pkgs.xdot
      (pkgs.makeDesktopItem {
        name = "xdot";
        desktopName = "xdot";
        exec = "xdot %U";
  })];};
in {
  home.packages = [
    myxdot
  ];
  #MC Open *.dot files with xdot.desktop by default.
  xdg.mime.types.dot = {
    name = "graphviz-dot";
    type = "text/graphviz-dot";
    pattern = "*.dot";
    defaultApp = "xdot.desktop";
  };
}
