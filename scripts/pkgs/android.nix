#!/usr/bin/env nix-build

# https://nixos.wiki/wiki/Android
#  Building Android applications with the Nix package manager: https://sandervanderburg.blogspot.com/2014/02/reproducing-android-app-deployments-or.html
let
  # current nixpkgs-unstable
  pkgs = import (with import <nixpkgs> {}; fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "1c851e8c92b76a00ce84167984a7ec7ba2b1f29c";
    hash = "sha256-vRxti8pOuXS0rJmqjbD8ueEEFXWSK22ISHoCWkhgzzg=";
  }){
    config.android_sdk.accept_license = true;
    config.allowUnfree = true;
  };
in pkgs.androidenv.emulateApp {
  name = "androidEmuApp";
  app = pkgs.fetchurl {
    url = "https://github.com/SimpleMobileTools/Simple-Calendar/releases/download/6.13.5/calendar-release.apk";
    sha256 = "12vzcd6klnk38b55szmd5a8ydc70fk6aak31qvlild83jy9z21zk";
  };
  enableGPU = false;
  # get these info by `pkgs/development/mobile/androidenv/repo.json`
  # see if installed `sdkmanager --list`
  platformVersion = "32";
  abiVersion = "x86";
  systemImageType = "google_apis";

  package = "com.simplemobiletools.calendar.pro";

  avdHomeDir = "$HOME/.android";
  sdkExtraArgs = {
    includeSystemImages = true;
  };
}
