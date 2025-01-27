{ config, pkgs, stdenv, lib, ... }:
{
  programs.firefox = {
    enable = true;
    # If state version ≥ 19.09 then this should be a wrapped Firefox
    package = pkgs.firefox.overrideAttrs (old: {
      desktopItem = old.desktopItem.override {
        exec = "env MOZ_USE_XINPUT2=1 firefox --name firefox %U";
      };
    });
    profiles.xieby1 = {
      # id is default 0, thus this profile is default
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        # 😾😾😾 Chinese users cannot use ad block extensions
        # https://discourse.mozilla.org/t/chinese-users-cant-use-ad-blocker-extensions/94823
        ublock-origin
      ];
      settings = {
        # Automatically enable extensions
        "extensions.autoDisableScopes" = 0;
      };
    };
  };
}
