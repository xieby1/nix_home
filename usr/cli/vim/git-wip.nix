#MC # git-wip: auto wip branch
{ config, pkgs, stdenv, lib, ... }:
let
  git-wip = pkgs.vimUtils.buildVimPlugin {
    name = "git-wip";
    src = pkgs.fetchFromGitHub {
      owner = "bartman";
      repo = "git-wip";
      rev = "1c095e93539261370ae811ebf47b8d3fe9166869";
      hash = "sha256-rjvg6sTOuUM3ltD3DuJqgBEDImLrsfdnK52qxCbu8vo=";
    };
    preInstall = "cd vim";
  };
in {
  programs.neovim = {
    plugins = [
      git-wip
    ];
  };
}
