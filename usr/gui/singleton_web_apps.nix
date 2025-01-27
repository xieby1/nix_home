{ config, pkgs, lib, ... }:
let
  # You Can Change To Chrome-Like Browser Here!
  chromeLikeBrowser = if (lib.meta.availableOn builtins.currentSystem pkgs.microsoft-edge.meta.platforms)
    then "${pkgs.microsoft-edge}/bin/microsoft-edge"
    else "${pkgs.chromium}/bin/chromium";

  singleton = pkgs.writeShellScriptBin "singleton.sh" ''
    if [[ $# -lt 2 || $1 == "-h" ]]
    then
      echo "Usage: ''${0##*/} <window> <command and its args>"
      echo "  Only start a app once, if the app is running"
      echo "  then bring it to foreground"
      exit 0
    fi

    if [[ "$1" == "kdeconnect.app" ]]
    then
      WID=$(${pkgs.xdotool}/bin/xdotool search --classname "$1")
    else
      WID=$(${pkgs.xdotool}/bin/xdotool search --onlyvisible --name "$1")
    fi

    if [[ -z $WID ]]
    then
      eval "''${@:2}"
    else
      for WIN in $WID
      do
        CURDESK=$(${pkgs.xdotool}/bin/xdotool get_desktop)
        ${pkgs.xdotool}/bin/xdotool set_desktop_for_window $WIN $CURDESK
        ${pkgs.xdotool}/bin/xdotool windowactivate $WIN
      done
    fi
  '';
  singleton_sh = "${singleton}/bin/singleton.sh";

  webapp_common = ''
    if [[ $# -lt 2 || "$1" == "-h" ]]
    then
      echo "Usage: ''${0##*/} <window> <url>"
      echo "  Only start a webapp once, if the app is running"
      echo "  then bring it to foreground"
      exit 0
    fi

    # check URL prefix
    URL=$2
    if [[ "$URL" =~ ^~ ]]
    then
      URL="file://$HOME/''${URL#\~/}"
    fi
    if [[ "$URL" =~ ^\/ ]]
    then
      URL="file://$URL"
    fi
    if [[ "$URL" =~ ^(file|https?)?:\/\/ ]]
    then
      true
    else
      URL="https://$URL"
    fi
  '';
  webapp = pkgs.writeShellScriptBin "webapp.sh" ''
    ${webapp_common}
    ${singleton_sh} "$1" ${chromeLikeBrowser} --app="$URL"
  '';
  webapp_no_cors = pkgs.writeShellScriptBin "webapp_no_cors.sh" ''
    ${webapp_common}
    ${singleton_sh} "$1" ${chromeLikeBrowser} --user-data-dir=~/.chrome_no_cors --disable-web-security --app="$URL"
  '';
  webapp_sh = "${webapp}/bin/webapp.sh";
  webapp_no_cors_sh = "${webapp_no_cors}/bin/webapp_no_cors.sh";
  open_my_cheatsheet_md_sh = pkgs.writeShellScript "open_my_cheatsheet_md" ''
     cd ${config.home.homeDirectory}/Documents/Tech
     kitty nvim my_cheatsheet.mkd -c Vista
     make
  '';
in
{
  home.packages = [singleton webapp webapp_no_cors];

  # gnome keyboard shortcuts
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/my_cheatsheet_html/"
    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/my_cheatsheet_md/"
    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/bing_dict/"
    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/hjxd_jp/"
    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/kdeconnect_app/"
    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/devdocs/"
  ];
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/my_cheatsheet_html" = {
    binding="<Alt>space";
    command="gtk-launch my_cheatsheet_html.desktop";
    name="cheatsheet";
  };
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/my_cheatsheet_md" = {
    binding="<Alt>c";
    command="gtk-launch my_cheatsheet_md.desktop";
    name="edit cheatsheet";
  };
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/bing_dict" = {
    binding="<Alt>b";
    command="gtk-launch bing_dict.desktop";
    name="bing dict";
  };
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/hjxd_jp" = {
    binding="<Alt>j";
    command="gtk-launch hjxd_jp.desktop";
    name="日语词典";
  };
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/kdeconnect_app" = {
    binding="<Alt>k";
    command="gtk-launch kdeconnect_app.desktop";
    name="KDE Connect";
  };
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/devdocs" = {
    binding="<Alt>d";
    command="gtk-launch devdocs.desktop";
    name="Devdocs";
  };

  xdg.desktopEntries = {
    # web apps
    ## microsoft's
    todo = {
      name = "Microsoft To Do";
      genericName = "ToDo";
      exec = "${webapp_sh} \"To Do\" https://to-do.live.com/";
      icon = builtins.fetchurl {
        url = "http://www.google.com/s2/favicons?domain=https://to-do.live.com&sz=128";
        name = "ToDo.png";
      };
    };
    calendar = {
      name = "Microsoft Calendar";
      exec = "${webapp_sh} Outlook https://outlook.live.com/calendar";
      icon = (pkgs.fetchurl {
        url = "https://cdn.cdnlogo.com/logos/o/82/outlook.svg";
        sha256 = "0544z9vmghp4lgapl00n99vksm0gq8dfwrp7rvfpp44njnh6b6dz";
      }).outPath;
    };
    outlook = {
      name = "Microsoft Outlook";
      exec = "${webapp_sh} Outlook https://outlook.live.com";
      icon = (pkgs.fetchurl {
        url = "https://cdn.cdnlogo.com/logos/o/82/outlook.svg";
        sha256 = "0544z9vmghp4lgapl00n99vksm0gq8dfwrp7rvfpp44njnh6b6dz";
      }).outPath;
    };
    word = {
      name = "Word";
      genericName = "office";
      exec = "${webapp_sh} Word https://www.office.com/launch/word";
      icon = (pkgs.fetchurl {
        url = "https://cdn.cdnlogo.com/logos/w/19/word.svg";
        sha256 = "1ig0d8afacfl7m1n0brx82iw8c2iif3skb8dwjly4fzxikzvfmn4";
      }).outPath;
    };
    excel = {
      name = "Excel";
      genericName = "office";
      exec = "${webapp_sh} Excel https://www.office.com/launch/excel";
      icon = (pkgs.fetchurl {
        url = "https://cdn.cdnlogo.com/logos/m/96/microsoft-excel.png";
        sha256 = "07ch9kb3s82m47mm414gvig6zg2h4yffmvjvg7bvr7sil8476cs8";
      }).outPath;
    };
    powerpoint = {
      name = "PowerPoint";
      genericName = "office ppt";
      exec = "${webapp_sh} PowerPoint https://www.office.com/launch/powerpoint";
      icon = (pkgs.fetchurl {
        url = "https://cdn.cdnlogo.com/logos/p/67/powerpoint.svg";
        sha256 = "1pnb2nna2b26kyn0i92xmgdpcrqhw1cpl3vv7vvvlsxrldndhclr";
      }).outPath;
    };
    onedrive = {
      name = "OneDrive";
      exec = "${webapp_sh} OneDrive https://onedrive.live.com";
      icon = (pkgs.fetchurl {
        url = "https://cdn.cdnlogo.com/logos/m/73/microsoft-onedrive.svg";
        sha256 = "10sjz81xjcqfkd7v11vhpvdp0s2a8la9wipc3aapgybg822vhjck";
      }).outPath;
    };
    ## others
    suishouji = {
      name = "随手记";
      genericName = "suishouji";
      exec = "${webapp_sh} 随手记 https://www.sui.com/";
      icon = (pkgs.fetchurl {
        url = "https://res.sui.com/favicon.ico";
        sha256 = "01vm275n169r0ly8ywgq0shgk8lrzg79d1aarshwybwxwffj4q0q";
      }).outPath;
    };
    webweixin = {
      name = "网页微信";
      genericName = "weixin";
      exec = ''${webapp_sh} "微信|weixin" https://wx.qq.com/'';
      icon = (pkgs.fetchurl {
        url = "https://cdn.cdnlogo.com/logos/w/79/wechat.svg";
        sha256 = "1xk1dsia6favc3p1rnmcncasjqb1ji4vkmlajgbks0i3xf60lskw";
      }).outPath;
    };
    my_cheatsheet_html = {
      name = "Cheatsheet HTML";
      genericName = "cheatsheet";
      exec = ''${webapp_sh} "markdown cheatsheet" ${config.home.homeDirectory}/Documents/Tech/my_cheatsheet.html'';
    };
    bing_dict = {
      name = "Bing Dict";
      genericName = "dictionary";
      exec = ''${webapp_sh} "搜索 词典" https://cn.bing.com/dict/'';
    };
    hjxd_jp = {
      name = "日语词典";
      genericName = "riyucidian";
      exec = "${webapp_sh} 日语词典 https://dict.hjenglish.com/jp/";
    };
    devdocs = {
      name = "DevDocs";
      genericName = "devdocs";
      exec = "${webapp_sh} DevDocs https://devdocs.io/";
      icon = (pkgs.fetchurl {
        url = "https://devdocs.io/images/webapp-icon-512.png";
        sha256 = "0bbimjp8r4fwzgd094wady2ady1fqz0crnyy2iwa835g7yivix24";
      }).outPath;
    };
    clash = let
      metacubexd = builtins.fetchTarball "https://github.com/MetaCubeX/metacubexd/archive/gh-pages.zip";
    in {
      name = "clash";
      exec = "${webapp_no_cors_sh} metacubexd file://${metacubexd}/index.html";
      icon = "${metacubexd}/pwa-192x192.png";
    };

    # singleton apps
    my_cheatsheet_md = {
      name = "Cheatsheet MD";
      genericName = "cheatsheet";
      exec = "${singleton_sh} my_cheatsheet.mkd ${open_my_cheatsheet_md_sh}";
    };
    kdeconnect_app = {
      name = "(S) KDE Connect App";
      genericName = "kdeconnect";
      exec = "${singleton_sh} kdeconnect.app kdeconnect-app";
    };
  };
}
