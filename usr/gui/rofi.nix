{ config, pkgs, stdenv, lib, ... }:
let
  my-rofi = pkgs.rofi.override {
    plugins = with pkgs; [
      # rofi-file-browser
    ];
  };
in
{
  home.packages = with pkgs; [
    my-rofi
  ];

  # gnome keyboard shortcuts
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/rofi_window/"
    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/rofi_x/"
  ];
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/rofi_window" = {
    binding="<Super>w";
    command="rofi -show window";
    name="rofi window";
  };
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/rofi_x" = let
    x = pkgs.writeScript "x" ''
      cd ${config.home.homeDirectory}/Gist/script/bash/
      xdotool type --clearmodifiers --delay 30 \
        "$(ls --color=never x-* | rofi -dmenu | xargs bash -c)"
    '';
  in {
    binding="<Super>x";
    command="${x}";
    name="rofi x";
  };

  home.file.rofi_config = {
    target = ".config/rofi/config.rasi";
    text = ''
      /* This is a comment */
      /* rofi -dump-config */

      configuration {
        modes: [
          window,
          drun,
          run,
          ssh
          /* file-browser-extended */
        ];
        terminal: "kitty";
        dpi: 1;
        show-icons: true;
      }
      filebrowser {
        directory: "~/Documents";
      }

      /* man rofi-theme */

      window {
        width: 80%;
      }
    '';
  };

  # home.file.rofi_file_browser_config = let
  #   openDir = pkgs.writeScript "openDir" ''
  #     if [[ -d "$1" ]]; then
  #       xdg-open "$1"
  #     elif [[ -f "$1" ]]; then
  #       xdg-open "''${1%/*}"
  #     fi
  #   '';
  # in {
  #   target = ".config/rofi/file-browser";
  #   text = ''
  #     # This is a comment
  #     dir ~/Documents
  #     depth 0
  #     no-sort-by-type
  #     sort-by-depth

  #     # BUG: rofi -show-icons causes segmentation fault
  #     # oc-search-path
  #     # oc-cmd "nautilus"
  #     # oc-cmd "${openDir}"
  #   '';
  # };
}
