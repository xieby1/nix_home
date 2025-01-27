{ config, pkgs, stdenv, lib, ... }:
let
  opt = import ../../opt.nix;
  tailscale-bash-completion = builtins.derivation {
    name = "tailscale-bash-completion";
    system = builtins.currentSystem;
    src = builtins.fetchurl "https://gist.githubusercontent.com/cmtsij/f0d0be209224a7bdd67592695e1427de/raw/tailscale";
    builder = pkgs.writeShellScript "tailscale-bash-completion-builder" ''
      source ${pkgs.stdenv}/setup
      dstdir=$out/share/bash-completion/completions
      dst=$dstdir/tailscale
      mkdir -p $dstdir
      cp $src $dst
    '';
  };
  tailscale-wrapper = {suffix, httpPort, socks5Port}: let
    tailscale-wrapped = pkgs.writeShellScriptBin "tailscale-${suffix}" ''
      tailscale --socket /tmp/tailscale-${suffix}.sock $@
    '';
    stateDir = "${config.home.homeDirectory}/.local/share/tailscale-${suffix}";
    tailscaled-wrapped = pkgs.writeShellScriptBin "tailscaled-${suffix}" ''
      TS_LOGS_DIR="${stateDir}" \
        ${pkgs.tailscale}/bin/tailscaled \
        --tun userspace-networking \
        --outbound-http-proxy-listen=localhost:${httpPort} \
        --socks5-server=localhost:${socks5Port} \
        --socket=/tmp/tailscale-${suffix}.sock \
        --state=${stateDir}/tailscaled.state \
        --statedir=${stateDir} \
        $@
    '';
    tailscale-wrapped-bash-completion = builtins.derivation {
      name = "tailscale-${suffix}-bash-completion";
      system = builtins.currentSystem;
      builder = pkgs.writeShellScript "tailscale-${suffix}-bash-completion-builder" ''
        source ${pkgs.stdenv}/setup
        reldir=share/bash-completion/completions
        dstdir=$out/$reldir
        dst=$dstdir/tailscale-${suffix}
        mkdir -p $dstdir
        touch $dst
        echo ". ${tailscale-bash-completion}/$reldir/tailscale" >> $dst
        echo "complete -F _tailscale tailscale-${suffix}" >> $dst
      '';
    };
  in {
    home.packages = [
      tailscale-wrapped
      tailscaled-wrapped
      tailscale-wrapped-bash-completion
    ];
    systemd.user.services."tailscaled-${suffix}" = {
      Unit = {
        Description = "Auto start tailscaled-${suffix} userspace network";
        After = ["clash.service"];
      };
      Install = {
        WantedBy = ["default.target"];
      };
      Service = {
        Environment = [
          "HTTPS_PROXY=http://127.0.0.1:${toString opt.proxyPort}"
          "HTTP_PROXY=http://127.0.0.1:${toString opt.proxyPort}"
          "https_proxy=http://127.0.0.1:${toString opt.proxyPort}"
          "http_proxy=http://127.0.0.1:${toString opt.proxyPort}"
        ];
        ExecStart = "${tailscaled-wrapped}/bin/tailscaled-${suffix}";
      };
    };
    programs.bash.bashrcExtra = lib.optionalString opt.isNixOnDroid ''
      # start tailscale-${suffix}
      if [[ -z "$(pidof tailscaled-${suffix})" ]]; then
          tmux new -d -s tailscaled-${suffix} tailscaled-${suffix}
      fi
    '';
  };
in {
  imports = [{
    home.packages = [pkgs.tailscale tailscale-bash-completion];
  }
    # (tailscale-wrapper {suffix="headscale"; httpPort="1055"; socks5Port="1065";})
    (tailscale-wrapper {suffix="official";  httpPort="1056"; socks5Port="1066";})
  ];
}
