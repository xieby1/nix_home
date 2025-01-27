let
  pkgs = import <nixpkgs> {};
  ccache_dir = toString ./. + "/.ccache";
  ccache14Stdenv = pkgs.ccacheStdenv.override {
    stdenv = pkgs.gcc14Stdenv;
    extraConfig = ''
      export CCACHE_COMPRESS=1
      export CCACHE_DIR="${ccache_dir}"
      export CCACHE_UMASK=007
      if [ ! -d "$CCACHE_DIR" ]; then
        echo "====="
        echo "Directory '$CCACHE_DIR' does not exist"
        echo "Please create it with:"
        echo "  mkdir -m0770 '$CCACHE_DIR'"
        echo "====="
        exit 1
      fi
      if [ ! -w "$CCACHE_DIR" ]; then
        echo "====="
        echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
        echo "Please verify its access permissions"
        echo "====="
        exit 1
      fi
    '';
  };
  ccacheMkShell = pkgs.mkShell.override {
    stdenv = ccache14Stdenv;
  };
in ccacheMkShell {
  name = "ccache-shell";
  shellHook = ''
    mkdir -m0770 -p ${ccache_dir}
  '';
}
