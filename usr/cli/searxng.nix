{ config, pkgs, stdenv, lib, ... }:
let
  opt = import ../../opt.nix;
  searxng_yml = builtins.toFile "searxng.yml" ''
    # https://docs.searxng.org/admin/settings/settings.html#settings-yml-location
    # The initial settings.yml we be load from these locations:
    # * the full path specified in the SEARXNG_SETTINGS_PATH environment variable.
    # * /etc/searxng/settings.yml

    # Default settings see <pkgs.searxng>/lib/python3.11/site-packages/searx/settings.yml
    use_default_settings: true

    search:
      autocomplete: "google"
      default_lang: "en"

    server:
      # Is overwritten by $SEARXNG_SECRET
      secret_key: ${if builtins.pathExists ~/Gist/Config/passwordFile
                    then builtins.readFile ~/Gist/Config/passwordFile
                    else "miao"}

    outgoing:
      proxies:
        all://:
          - http://127.0.0.1:${toString opt.proxyPort}

    engines:
      - name: bilibili
        engine: bilibili
        shortcut: bil
        disabled: false

      - name: bing
        engine: bing
        shortcut: bi
        disabled: false

      - name: qwant
        disabled: true
    ui:
      results_on_new_tab: true
  '';
in {
  systemd.user.services.searxng = {
    Unit = {
      Description = "Auto start searxng";
      After = ["network.target"];
    };
    Install = {
      WantedBy = ["default.target"];
    };
    Service = {
      Environment = [
        "SEARXNG_SETTINGS_PATH=${searxng_yml}"
      ];
      ExecStart = "${pkgs.searxng}/bin/searx-run";
    };
  };
}
