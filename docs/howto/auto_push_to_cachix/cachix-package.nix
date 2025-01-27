#MC # cachixPackage
#MC
#MC This file try to implement a package wrapper, which will automatically push `pkg` to cachix upon building.
#MC However, this method seems not work, due to limited resources in nix-build environment.
#MC For more details, see [here](./index.md).
{ cachix
, stdenv
, writeShellScript
}:

{ pkg
, sha256
, cachix_dhall
, cachix_name
, name ? "cachixed"
}:

builtins.derivation {
  inherit name;
  system = builtins.currentSystem;
  builder = writeShellScript "cachix-package-builder" ''
    source ${stdenv}/setup
    echo ${pkg} > $out
    if [[ -f "${cachix_dhall}" ]]; then
      ${cachix}/bin/cachix -c ${cachix_dhall} push ${cachix_name} ${pkg}
      result=$?
      echo result $result
      exit $result
    fi
  '';

  outputHashMode = "flat";
  outputHashAlgo = "sha256";
  outputHash = sha256;
}
