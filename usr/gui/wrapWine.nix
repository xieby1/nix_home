# based on https://github.com/lucasew/nixcfg/blob/49d44c1a655f1c20d7354ecea942c78704067d50/pkgs/wrapWine.nix
{ pkgs ? import <nixpkgs> {} }:
let
  inherit (builtins) length concatStringsSep;
  inherit (pkgs) lib cabextract
    writeShellScriptBin symlinkJoin;
  inherit (lib) makeBinPath;
in
{ is64bits ? false
, wine ? if is64bits then pkgs.wineWowPackages.stable else pkgs.wine
, wineFlags ? ""
, executable
, chdir ? null
, name
, tricks ? [ ]
, setupScript ? ""
, firstrunScript ? ""
, home ? ""
, regfile ? null
}:
let
  wineBin = "${wine}/bin/wine${if is64bits then "64" else ""}";
  requiredPackages = [
    wine
    cabextract
  ];
  PATH = makeBinPath requiredPackages;
  NAME = name;
  WINEARCH =
    if is64bits
    then "win64"
    else "win32";
  WINE_NIX = "$HOME/.wine-nix";
  WINEPREFIX = "${WINE_NIX}/${name}";
  setupHook = ''
    ${wine}/bin/wineboot
  '';
  tricksHook =
    if (length tricks) > 0 then
      let
        tricksStr = concatStringsSep " " tricks;
        tricksCmd = ''
          ${pkgs.winetricks}/bin/winetricks ${tricksStr}
        '';
      in
      tricksCmd
    else "";
  run = writeShellScriptBin name ''
    export APP_NAME="${NAME}"
    export WINEARCH=${WINEARCH}
    export WINE_NIX=${WINE_NIX}
    export PATH=$PATH:${PATH}
    export WINEPREFIX="${WINEPREFIX}"
    export EXECUTABLE="${executable}"
    mkdir -p "$WINE_NIX"
    ${setupScript}
    if [ ! -e "$EXECUTABLE" ] # if the executable does not exist
    then
      ${if regfile!=null
        then ''${wineBin} regedit /C ${regfile}''
        else ""
      }
      ${setupHook}
      ${tricksHook}
      ${firstrunScript}
    else # no automatically run after installation!
      ${if chdir != null
        then ''cd "${chdir}"''
        else ""}
      if [ ! "$REPL" == "" ]; # if $REPL is setup then start a shell in the context
      then
        bash
        exit 0
      fi

      ${wineBin} ${wineFlags} "$EXECUTABLE" "$@"
    fi
  '';
  clean = writeShellScriptBin "${name}-clean" ''
    read -p "Are you sure you want to clean ${WINEPREFIX}? <y/N> " prompt
    if [[ $prompt =~ [yY](es)* ]]; then
      rm ${WINEPREFIX} -rf
    fi
  '';
  winecfg = writeShellScriptBin "${name}-cfg" ''
    export WINEARCH=${WINEARCH}
    WINEPREFIX=${WINE_NIX}/${name} winecfg $@
  '';
  _wine = writeShellScriptBin "${name}-wine" ''
    export WINEARCH=${WINEARCH}
    WINEPREFIX=${WINE_NIX}/${name} ${wineBin} $@
  '';
in
symlinkJoin {
  inherit name;
  paths = [run clean winecfg _wine];
}
