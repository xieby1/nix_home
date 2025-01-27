#MC # cli-extra.nix: Extra CLI configs (added to minial cli.nix)
{ config, pkgs, stdenv, lib, ... }:
let
  opt = import ../opt.nix;
in {
  imports = [{
    home.packages = let
      pandora = pkgs.python3Packages.callPackage ./cli/pandora-chatgpt.nix {};
      chatgpt = pkgs.writeShellScriptBin "chatgpt" ''
        ${pandora}/bin/pandora -t ~/Gist/Pandora-ChatGPT/access_token.dat $@
      '';
    in [pandora chatgpt];
  }{
    home.packages = [
      pkgs.act
      (pkgs.writeShellScriptBin "act-podman" ''
        export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock
        CMD=(
          "${pkgs.act}/bin/act"
          "--bind"

          # use podman
          "--container-daemon-socket" "unix://$XDG_RUNTIME_DIR/podman/podman.sock"

          # use host proxy
          "--container-options" "--network=host"
          "--env" "HTTPS_PROXY='http://127.0.0.1:${toString opt.proxyPort}'"
          "--env" "HTTP_PROXY='http://127.0.0.1:${toString opt.proxyPort}'"
          "--env" "FTP_PROXY='http://127.0.0.1:${toString opt.proxyPort}'"
          "--env" "https_proxy='http://127.0.0.1:${toString opt.proxyPort}'"
          "--env" "http_proxy='http://127.0.0.1:${toString opt.proxyPort}'"
          "--env" "ftp_proxy='http://127.0.0.1:${toString opt.proxyPort}'"

          "$@"
        )
        eval "''${CMD[@]}"
      '')
    ];
  }];

  home.packages = with pkgs; [
    # tools
    imagemagick

    # programming
    ## c
    cling # c/cpp repl
    ## javascript
    nodePackages.typescript
    ### node
    nodejs
    ## java
    openjdk

    ### pdfcrop
    (texlive.combine {inherit (pkgs.texlive) scheme-minimal pdfcrop;})
    # runXonY
    qemu
  ] ++ lib.optional (builtins.currentSystem == "x86_64-linux") quickemu;
}
