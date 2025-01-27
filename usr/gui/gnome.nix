{ config, pkgs, stdenv, lib, ... }:
# gnome extensions and settings
# no need log out to reload extension: <alt>+F2 r
let
  opt = import ../../opt.nix;
in{
  home.packages = (with pkgs; [
    gnome-sound-recorder
    dconf-editor
    devhelp
  ])
  ++ (with pkgs.gnomeExtensions; [
    unite
    clipboard-indicator
    bing-wallpaper-changer
    # random-wallpaper-wip-v3
    gtile
    pkgs.pkgsu.gnomeExtensions.hide-top-bar
    dash-to-dock
    always-show-titles-in-overview
    customize-ibus
    # replace system-monitor(-next) with vitals
    # refers to https://github.com/mgalgs/gnome-shell-system-monitor-applet/issues/57
    # vitals
    system-monitor-next
  ]);

  # Setting: `gsettings set <key(dot)> <value>`
  # Getting: `dconf dump /<key(path)>`
  dconf.settings = {
    "org/gnome/shell" = {
      disable-extension-version-validation = true;
      ## enabled gnome extensions
      disable-user-extensions = false;
      disabled-extensions = [];
      enabled-extensions = [
        "BingWallpaper@ineffable-gmail.com"
        "clipboard-indicator@tudmotu.com"
        "gTile@vibou"
        "hidetopbar@mathieu.bidon.ca"
        # "Vitals@CoreCoding.com"
        "system-monitor-next@paradoxxx.zero.gmail.com"
        "unite@hardpixel.eu"
        "dash-to-dock@micxgx.gmail.com"
        # "randomwallpaper@iflow.space"
        "Always-Show-Titles-In-Overview@gmail.com"
        "customize-ibus@hollowman.ml"
      ];

      ## dock icons
      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "firefox.desktop"
        "microsoft-edge.desktop"
        "calendar.desktop"
        "todo.desktop"
        "google-chrome.desktop"
        ];
    };
    ## extensions settings
    # "org/gnome/shell/extensions/vitals" = {
    #   fixed-widths = true;
    #   hide-icons = true;
    #   hot-sensors = [
    #     "_processor_usage_"
    #     "_memory_usage_"
    #     "__network-rx_max__"
    #     "__network-tx_max__"
    #   ];
    #   show-fan = false;
    #   show-system = false;
    #   show-temperature = false;
    #   show-voltage = false;
    #   update-time = 2;
    # };
    "org/gnome/shell/extensions/system-monitor" = {
      compact-display = true;
      icon-display = false;
      cpu-style = "digit";
      memory-style = "digit";
      net-style = "digit";
    };
    "org/gnome/shell/extensions/gtile" = {
      animation=true;
      global-presets=true;
      grid-sizes="6x4,8x6";
      preset-resize-1=["<Super>bracketleft"];
      preset-resize-2=["<Super>bracketright"];
      preset-resize-3=["<Super>period"];
      preset-resize-4=["<Super>slash"];
      preset-resize-5=["<Super>apostrophe"];
      preset-resize-6=["<Super>semicolon"];
      preset-resize-7=["<Super>comma"];
      resize1="2x2 1:1 1:1";
      resize2="2x2 2:1 2:1";
      resize3="2x2 1:2 1:2";
      resize4="2x2 2:2 2:2";
      resize5="4x8 2:2 3:7";
      resize6="1x2 1:1 1:1";
      resize7="1x2 1:2 1:2";
      show-icon=false;
    };

    "org/gnome/desktop/session" = {
      idle-delay=lib.hm.gvariant.mkUint32 0; # never turn off screen
    };
    "org/gnome/settings-daemon/plugins/power" = {
      ambient-enabled=false;
      idle-dim=false;
      power-button-action="nothing";
      sleep-inactive-ac-timeout=3600;
      sleep-inactive-ac-type="nothing";
      sleep-inactive-battery-type="suspend";
    };
    "org/gnome/shell/extensions/hidetopbar" = {
      mouse-sensitive = true;
      enable-active-window=false;
      enable-intellihide=true;
      shortcut-delay = 0.0;
      shortcut-keybind = ["<Super>h"];
    };
    "org/gnome/shell/extensions/unite" = {
      app-menu-ellipsize-mode="end";
      extend-left-box=false;
      greyscale-tray-icons=false;
      hide-app-menu-icon=false;
      hide-dropdown-arrows=true;
      hide-window-titlebars="always";
      notifications-position="center";
      reduce-panel-spacing=true;
      show-window-buttons="always";
      use-activities-text = false;
      window-buttons-placement="last";
      window-buttons-theme="materia";
      restrict-to-primary-screen=false;
    };
    "org/gnome/shell/extensions/bingwallpaper" = {
      market="zh-CN";
      delete-previous=true;
      download-folder="/tmp/pictures";
    };
    "org/gnome/shell/extensions/dash-to-dock" = {
      click-action="focus-or-appspread";
    };
    "org/gnome/shell/extensions/space-iflow-randomwallpaper" = {
      auto-fetch = true;
      change-lock-screen = true;
      hours = 8;
      minutes = 29;
      source = "genericJSON";
      # source = "wallhaven";
    };
    "org/gnome/shell/extensions/space-iflow-randomwallpaper/genericJSON" = {
      generic-json-request-url = "http://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=zh-CN";
      generic-json-response-path = "$.images[0].url";
      generic-json-url-prefix = "http://www.bing.com";
    };
    "org/gnome/shell/extensions/space-iflow-randomwallpaper/wallhaven" ={
      wallhaven-keyword="cardcaptor sakura";
    };


    # predefined keyboard shortcuts
    "org/gnome/desktop/wm/keybindings" = {
      switch-applications=[];
      switch-applications-backward=[];
      switch-windows=["<Alt>Tab"];
      switch-windows-backward=["<Shift><Alt>Tab"];
      maximize=["<Super>Up"];
      unmaximize=["<Super>Down"];
      minimize=[];
      move-to-workspace-left=["<Control>Home"];
      move-to-workspace-right=["<Control>End"];
    };
    "org/gnome/shell/extensions/clipboard-indicator" =
    {
      move-item-first=true;
    };

    # nautilus
    "org/gtk/settings/file-chooser" = {
      sort-directories-first=true;
    };

    "org/gnome/desktop/interface" = {
      enable-hot-corners=false;
      show-battery-percentage=true;
      switch-input-source=["<Control>space"];
      switch-input-source-backward=["<Shift><Control>space"];
    };

    # proxy
    "system/proxy" = {mode = "manual";};
    "system/proxy/ftp" = {host="127.0.0.1"; port=opt.proxyPort;};
    "system/proxy/http" = {host="127.0.0.1"; port=opt.proxyPort;};
    "system/proxy/https" = {host="127.0.0.1"; port=opt.proxyPort;};

    # input method
    "org/gnome/desktop/input-sources" = {
      sources = with lib.hm.gvariant; mkArray
      "(${lib.concatStrings [type.string type.string]})" [
        (mkTuple ["xkb"  "us"])
        (mkTuple ["ibus" "rime"])
        (mkTuple ["ibus" "mozc-jp"])
        (mkTuple ["ibus" "hangul"])
      ];
    };
    "org/gnome/shell/extensions/customize-ibus" = {
      candidate-orientation = lib.hm.gvariant.mkUint32 1;
      custom-font="Iosevka Nerd Font 16";
      enable-orientation=true;
      input-indicator-only-on-toggle=false;
      input-indicator-only-use-ascii=false;
      use-custom-font=true;
      use-indicator-show-delay=true;
    };
    "org/gnome/mutter" = {
      dynamic-workspaces = true;
    };
  };

  # inspired by https://discourse.nixos.org/t/how-to-set-the-bookmarks-in-nautilus/36143
  home.activation.nautilus_bookmarks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # WSL2 may not have folder ~/.config/gtk-3.0
    $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ~/.config/gtk-3.0
    $DRY_RUN_CMD ln -sf $VERBOSE_ARG ~/Gist/Config/nautilus_bookmarks ~/.config/gtk-3.0/bookmarks
  '';
}
