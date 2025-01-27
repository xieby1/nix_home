#!/usr/bin/env -S nix-shell --keep miao
# --pure: start a pure reproducible shell
{ pkgs ? import <nixpkgs> {}
}:
pkgs.mkShell {
  name="dev-environment";
  buildInputs = with pkgs; [
    texlive.combined.scheme-full # HUGE SIZE!

    tmux
  ];
  shellHook = ''
    # install texlive permenant
    nix-env -q "texlive.*"
    if [[ ''$? -ne 0 ]]
    then
      nix-env -f '<nixpkgs>' -iA texlive.combined.scheme-full
    fi

    tmux
    exit
  '';
}
