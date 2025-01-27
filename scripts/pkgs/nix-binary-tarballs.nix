#!/usr/bin/env -S nix-build -o nix-binary-tarballs
#MC # Nix official installer
#MC
#MC The `binaryTarball` function is extracted from [nix-2.18's flake.nix](https://github.com/NixOS/nix/blob/2.18.2/flake.nix)
#MC
#MC **Noted**:
#MC Although the latest nix has seperate binaryTarball as a independent file,
#MC current unstable nixpkgs still use nix-2.18,
#MC which embed binaryTarball function in nix/flake.nix.
#MC If reuse the binaryTarball file in new nix, then this script can be hugely simplified,
#MC e.g. [nix-binary-tarballs-new.nix](./nix-binary-tarballs-new.nix.md).
#MC As long as, new nix is merged to mainline nixpkgs,
#MC I will deprecate this script and adopt the new script.
let
  pkgs = import <nixpkgs> {};
  binaryTarball =
    { nix
    , buildPackages
    , cacert
    }:
    let
      installerClosureInfo = buildPackages.closureInfo { rootPaths = [ nix cacert ]; };
    in buildPackages.runCommand "nix-binary-tarball-${nix.version}" {
      #nativeBuildInputs = lib.optional (system != "aarch64-linux") shellcheck;
      meta.description = "Distribution-independent Nix bootstrap binaries for ${nix.stdenv.system}";
    } ''
      cp ${installerClosureInfo}/registration $TMPDIR/reginfo
      cp ${nix.src}/scripts/create-darwin-volume.sh $TMPDIR/create-darwin-volume.sh
      substitute ${nix.src}/scripts/install-nix-from-closure.sh $TMPDIR/install \
        --subst-var-by nix ${nix} \
        --subst-var-by cacert ${cacert}
    
      substitute ${nix.src}/scripts/install-darwin-multi-user.sh $TMPDIR/install-darwin-multi-user.sh \
        --subst-var-by nix ${nix} \
        --subst-var-by cacert ${cacert}
      substitute ${nix.src}/scripts/install-systemd-multi-user.sh $TMPDIR/install-systemd-multi-user.sh \
        --subst-var-by nix ${nix} \
        --subst-var-by cacert ${cacert}
      substitute ${nix.src}/scripts/install-multi-user.sh $TMPDIR/install-multi-user \
        --subst-var-by nix ${nix} \
        --subst-var-by cacert ${cacert}
    
      if type -p shellcheck; then
        # SC1090: Don't worry about not being able to find
        #         $nix/etc/profile.d/nix.sh
        shellcheck --exclude SC1090 $TMPDIR/install
        shellcheck $TMPDIR/create-darwin-volume.sh
        shellcheck $TMPDIR/install-darwin-multi-user.sh
        shellcheck $TMPDIR/install-systemd-multi-user.sh
    
        # SC1091: Don't panic about not being able to source
        #         /etc/profile
        # SC2002: Ignore "useless cat" "error", when loading
        #         .reginfo, as the cat is a much cleaner
        #         implementation, even though it is "useless"
        # SC2116: Allow ROOT_HOME=$(echo ~root) for resolving
        #         root's home directory
        shellcheck --external-sources \
          --exclude SC1091,SC2002,SC2116 $TMPDIR/install-multi-user
      fi
    
      chmod +x $TMPDIR/install
      chmod +x $TMPDIR/create-darwin-volume.sh
      chmod +x $TMPDIR/install-darwin-multi-user.sh
      chmod +x $TMPDIR/install-systemd-multi-user.sh
      chmod +x $TMPDIR/install-multi-user
      dir=nix-${nix.version}-${nix.stdenv.system}
      fn=$out/$dir.tar.xz
      mkdir -p $out/nix-support
      echo "file binary-dist $fn" >> $out/nix-support/hydra-build-products
      tar cvfJ $fn \
        --owner=0 --group=0 --mode=u+rw,uga+r \
        --mtime='1970-01-01' \
        --absolute-names \
        --hard-dereference \
        --transform "s,$TMPDIR/install,$dir/install," \
        --transform "s,$TMPDIR/create-darwin-volume.sh,$dir/create-darwin-volume.sh," \
        --transform "s,$TMPDIR/reginfo,$dir/.reginfo," \
        --transform "s,$NIX_STORE,$dir/store,S" \
        $TMPDIR/install \
        $TMPDIR/create-darwin-volume.sh \
        $TMPDIR/install-darwin-multi-user.sh \
        $TMPDIR/install-systemd-multi-user.sh \
        $TMPDIR/install-multi-user \
        $TMPDIR/reginfo \
        $(cat ${installerClosureInfo}/store-paths)
    '';
in pkgs.symlinkJoin {
  name = "nix-binary-tarballs";
  paths = [
    # local nix installer
    (pkgs.callPackage binaryTarball {})
    # riscv64 nix installer
    (pkgs.callPackage binaryTarball {nix=pkgs.pkgsCross.riscv64.nix;})
    # loongarch64 nix installer
    (pkgs.callPackage binaryTarball {nix=pkgs.pkgsCross.loongarch64-linux.nix;})
  ];
}
