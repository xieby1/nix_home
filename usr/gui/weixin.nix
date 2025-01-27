{ pkgs ? import <nixpkgs> {}
, wrapWine ? import ./wrapWine.nix {inherit pkgs;}
}:

let
  name = "weixin";
  installer = builtins.fetchurl "https://dldir1.qq.com/weixin/Windows/WeChatSetup.exe";
  regfile = builtins.toFile "${name}.reg" ''
    Windows Registry Editor Version 5.00

    # [HKEY_LOCAL_MACHINE\System\CurrentControlSet\Hardware Profiles\Current\Software\Fonts]
    # "LogPixels"=dword:000000F0

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
    firstrunScript = ''
      # prevent weixin polluting my Documents folder
      rm -f $WINEPREFIX/drive_c/users/$USER/Documents
      mkdir -p $WINEPREFIX/drive_c/users/$USER/Documents

      wine ${installer}

      # 占用磁盘空间持续增加
      # https://github.com/vufa/deepin-wine-wechat-arch/issues/225
      mkdir -p $WINEPREFIX/drive_c/users/xieby1/AppData/Roaming/Tencent/WeChat/xweb/crash/Crashpad/
      touch $WINEPREFIX/drive_c/users/xieby1/AppData/Roaming/Tencent/WeChat/xweb/crash/Crashpad/reports
    '';
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
