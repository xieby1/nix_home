{ pkgs, config, ... }:

{
  # Simply install just the packages
  environment.packages = with pkgs; [
    # User-facing stuff that you really really want to have
    vim  # or some other editor, e.g. nano or neovim

    # Some common stuff that people expect to have
    #diffutils
    #findutils
    #utillinux
    #tzdata
    #hostname
    #man
    #gnugrep
    #gnupg
    #gnused
    #gnutar
    #bzip2
    #gzip
    #xz
    #zip
    #unzip
  ];

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "21.11";

  # After installing home-manager channel like
  #   nix-channel --add https://github.com/rycee/home-manager/archive/release-21.11.tar.gz home-manager
  #   nix-channel --update
  # you can configure home-manager in here like
  home-manager.config = import ./usr/cli.nix;
  #home-manager.config =
  #  { pkgs, lib, ... }:
  #  {
  #    # Read the changelog before changing this value
  #    home.stateVersion = "21.11";
  #
  #    # Use the same overlays as the system packages
  #    nixpkgs = { inherit (config.nixpkgs) overlays; };
  #
  #    # insert home-manager config
  #  };
  # If you want the same pkgs instance to be used for nix-on-droid and home-manager
  #home-manager.useGlobalPkgs = true;
}

# vim: ft=nix
