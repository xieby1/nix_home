let
  pkgs = import <nixpkgs> {};
  squashfuse-with-headers = pkgs.pkgsStatic.squashfuse.overrideAttrs (old: {
    src = pkgs.fetchurl {
      url = "https://github.com/vasi/squashfuse/archive/e51978c.tar.gz";
      hash = "sha256-9UQCmtMNj73k5FQMV0uM3G04uU3wJamNhVGpRB8H00E=";
    };
    postInstall = ''
      mkdir -p $out/include/squashfuse
      cp *.h $out/include/squashfuse
    '';
  });
  srcRev = "c1ea7509bc179a05d907baca64f41875662f35f2";
in pkgs.stdenv.mkDerivation {
  name = "appimage-runtime";
  src = pkgs.fetchFromGitHub {
    owner = "AppImage";
    repo = "type2-runtime";
    rev = "${srcRev}";
    sha256 = "1gr853iz1x6pgyav3w1kqaaaz2ybbx67dcg74kj54yrwlakrh165";
  };
  nativeBuildInputs = with pkgs; [
    pkg-config
  ];
  buildInputs = (with pkgs.pkgsStatic; [
    squashfuse-with-headers
    fuse
    zstd
    zlib

    lz4.out
    lzo
    lzma.out
  ]) ++ (with pkgs; [
    glibc.static
  ]);
  sourceRoot = "source/src/runtime";
  buildPhase = ''
    export CFLAGS="-std=gnu99 -s -Os -D_FILE_OFFSET_BITS=64 -DGIT_COMMIT=\"${srcRev}\" -T data_sections.ld -ffunction-sections -fdata-sections -Wl,--gc-sections -static"
    export LIBS="-lsquashfuse -lsquashfuse_ll -lzstd -lz -llz4 -llzo2 -llzma"
    $CC -I${squashfuse-with-headers}/include/squashfuse -I${pkgs.pkgsStatic.fuse}/include/fuse -o runtime-fuse2.o -c $CFLAGS runtime.c
    $CC $CFLAGS runtime-fuse2.o $LIBS -lfuse -o runtime-fuse2
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp runtime-fuse2 $out/bin/
  '';
}

# in pkgs.mkShell {
#   name = "appimage-runtime";
#   packages = (with pkgs.pkgsStatic; [
#     squashfuse-with-headers
#     fuse
#     zstd
#     zlib

#     lz4.out
#     lzo
#     lzma.out
#   ]) ++ (with pkgs; [
#     glibc.static
#     pkg-config
#   ]);
# }

# in (pkgs.buildFHSUserEnv {
#   name = "appimage-runtime-fhs";
#   targetPkgs = pkgs: (with pkgs.pkgsStatic; [
#     squashfuse-with-headers
#     fuse
#     zstd
#     zlib

#     lz4.out
#     lzo
#     lzma.out
#   ]) ++ (with pkgs; [
#     glibc.static
#     pkg-config
#   ]);
# }).env
