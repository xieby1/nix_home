let
  name = "weixin";
  pkgs = import <nixpkgs> {};
  wrapWine = import ./wrapWine.nix {inherit pkgs;};
  installer = builtins.fetchurl "https://dldir1.qq.com/weixin/Windows/WeChatSetup.exe";
  regfile = builtins.toFile "${name}.reg" ''
    Windows Registry Editor Version 5.00

    [HKEY_LOCAL_MACHINE\System\CurrentControlSet\Hardware Profiles\Current\Software\Fonts]
    "LogPixels"=dword:000000F0

    [HKEY_CURRENT_USER\Software\Wine\X11 Driver]
    "Decorated"="N"
  '';
  bin = wrapWine {
    inherit name;
    executable = "$WINEPREFIX/drive_c/Program Files/Tencent/WeChat/WeChat.exe";
    tricks = ["riched20" "msls31"];
    setupScript = ''
      LANG="zh_CN.UTF-8"
    '';
    firstrunScript = "wine ${installer}";
    inherit regfile;
  };
  desktop = pkgs.makeDesktopItem {
    inherit name;
    desktopName = "Wine微信";
    genericName = "weixin";
    type = "Application";
    exec = "${bin}/bin/${name}";
    icon = pkgs.fetchurl {
      url = "https://cdn.cdnlogo.com/logos/w/79/wechat.svg";
      sha256 = "1xk1dsia6favc3p1rnmcncasjqb1ji4vkmlajgbks0i3xf60lskw";
    };
  };
in
pkgs.symlinkJoin {
  inherit name;
  paths = [bin desktop];
}
