{ config, pkgs, stdenv, lib, ... }:
let
  opt = import ../../opt.nix;
  clashctl = pkgs.callPackage ./clashctl.nix {};
in {
  imports = [{
    home.packages = [
      pkgs.clash-meta
    ] ++ lib.optional (!opt.isNixOnDroid) clashctl;
    cachix_packages = lib.optional (!opt.isNixOnDroid) clashctl;

    systemd.user.services.clash = {
      Unit = {
        Description = "Auto start clash";
        After = ["network.target"];
      };
      Install = {
        WantedBy = ["default.target"];
      };
      Service = {
        ExecStart = "${pkgs.clash-meta.outPath}/bin/clash-meta -d ${config.home.homeDirectory}/Gist/clash";
      };
    };
    programs.bash.bashrcExtra = lib.mkBefore (lib.optionalString (!opt.isNixOnDroid) ''
      # proxy
      ## default
      HTTP_PROXY="http://127.0.0.1:${toString opt.proxyPort}/"
      ## microsoft wsl
      # if [[ $(uname -r) == *"microsoft"* ]]; then
      #     hostip=$(cat /etc/resolv.conf | grep nameserver | awk '{ print $2 }')
      #     export HTTP_PROXY="http://$hostip:${toString opt.proxyPort}"
      # fi
      export HTTPS_PROXY="$HTTP_PROXY"
      export HTTP_PROXY="$HTTP_PROXY"
      export FTP_PROXY="$HTTP_PROXY"
      export http_proxy="$HTTP_PROXY"
      export https_proxy="$HTTP_PROXY"
      export ftp_proxy="$HTTP_PROXY"
    '');
  }];
}
