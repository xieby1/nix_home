let
  name = "perl";
  pkgs = import <nixpkgs> {};
  fhsEnv = pkgs.buildFHSUserEnv {
    name = "${name}-fhs";
    targetPkgs = pkgs: with pkgs; [
      gnumake
    ];
    runScript = (pkgs.writeShellScript "${name}-fhsbuilder" ''
      ls
      cd $src/tools/src
      ls
      DOPERL=1 ./buildtools
    '');
  };
in builtins.derivation {
  inherit name;
  system = builtins.currentSystem;
  src = /home/xieby1/Codes/spec2000;
  builder = "${fhsEnv}/bin/${fhsEnv.name}";
}
