{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  qt5
}:
let
  version = "0.05";
  rpath = lib.makeLibraryPath [
    qt5.qtbase
  ] + ":${stdenv.cc.cc.lib}/lib64";
  src =
    if stdenv.hostPlatform.system == "x86_64-linux" then
      fetchurl {
        urls = [
          "https://github.com/horsicq/XELFViewer/releases/download/0.05/xelfviewer_0.05_Ubuntu_22.04_amd64.deb"
        ];
        sha256 = "0l6j0pnpfzwr8205xzis95k4x2la0mfy08bv6hfg32rh3bw906bz";
      }
    else
      throw "xelfviewer is not supported on ${stdenv.hostPlatform.system}";
in
stdenv.mkDerivation {
  pname = "xelfviewer";
  inherit version;

  system = "x86_64-linux";

  inherit src;

  nativeBuildInputs = [ qt5.wrapQtAppsHook ];

  buildInputs = [ dpkg ];

  dontUnpack = true;
  installPhase = ''
    mkdir -p $out
    dpkg-deb -x $src $out
    mv $out/usr/* $out/
    rm -r $out/usr
  '';

  postFixup = ''
    for file in $(find $out -type f \( -perm /0111 -o -name \*.so\* \) ); do
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$file" || true
      patchelf --set-rpath ${rpath}:$out/lib/xelfviewer $file || true
    done
  '';

  meta = with lib; {
    description = "XELFViewer";
    homepage = "https://github.com/horsicq/XELFViewer";
    license = licenses.mit;
    maintainers = with maintainers; [ xieby1 ];
    platforms = [ "x86_64-linux" ];
  };
}
