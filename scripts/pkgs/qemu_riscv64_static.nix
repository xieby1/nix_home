#!/usr/bin/env nix-build
# xieby1: 2022.05.24
# build static qemu (current version 6.1.1) into ./result/
# $ nix-build <this-file> -A qemu
# build static qemu-3.1.0 into ./result/
# $ nix-build <this-file> -A qemu31
# build and install static qemu
# $ nix-env -i -f <this-file> -A qemu
# build and install static qemu-3.1.0
# $ nix-env -i -f <this-file> -A qemu31
let
  pinnedPkgsSrc = builtins.fetchTarball {
    name = "nixos-static-qemu";
    url = "https://github.com/nixos/nixpkgs/archive/e7d63bd0d50df412f5a1d8acfa3caae75522e347.tar.gz";
    sha256 = "132pc4f9ixisyv4117p2jirmlyl6sd76bfaz33rhlcwakg7bhjm7";
  };
  # pkgs = import pinnedPkgsSrc {};
  # mypkgs = import pinnedPkgsSrc {
  pkgs = import <nixpkgs> {};
  mypkgs = import <nixpkgs> {
    overlays = [(self: super: {

      cdparanoiaIII = super.pkgsStatic.cdparanoiaIII.overrideAttrs (old: {
        preConfigure = old.preConfigure + ''
          cp ${super.gnu-config}/config.sub configure.sub
          cp ${super.gnu-config}/config.guess configure.guess
        '';
        # Makefile needs this to compile static
        STATIC="TRUE";
        buildPhase = ''
          make lib
          make cdparanoia
        '';
        preInstallPhases = ["preInstallPhase"];
        preInstallPhase = ''
          sed -i '/so/d' Makefile
        '';
      });

      liburing = super.pkgsStatic.liburing.overrideDerivation (old: {
        configureFlags = "";
        ENABLE_SHARED = 0;
      });

      # p11-kit cannot be used as a static library
      # https://github.com/p11-glue/p11-kit/issues/355
      p11-kit = super.pkgsMusl.p11-kit;
      # gnutls depends on p11-kit
      gnutls = super.pkgsMusl.gnutls;

      pam = super.pkgsStatic.openpam;

      # support both static and shared
      libselinux = (super.pkgsMusl.libselinux.override {
        libsepol = super.pkgsStatic.libsepol;
      }).overrideAttrs (old: {
         makeFlags = old.makeFlags ++ [
           "LIBDIR=$(out)/lib"
         ];
      });

      glib = (super.pkgsStatic.glib.override {
        meson = pkgs.meson;
        ninja = pkgs.ninja;
        pkg-config = pkgs.pkg-config;
        perl = pkgs.perl;
        python3 = pkgs.python3;
        gettext = pkgs.gettext;
        gtk-doc = pkgs.gtk-doc;
        docbook_xsl = pkgs.docbook_xsl;
        docbook_xml_dtd_45 = pkgs.docbook_xml_dtd_45;
        libxml2 = pkgs.libxml2;
      }).overrideAttrs (old: {
        outputs = super.lib.lists.remove "devdoc" old.outputs;
        buildInputs = old.buildInputs ++ [
          super.pkgsStatic.libsepol
        ];
        preBuild = ''
          sed -i "s/get_option('libmount')/get_option('libmount'), static: true/g" ../meson.build
          sed -i "s/get_option('selinux')/get_option('selinux'), static: true/g" ../meson.build
        '';
        # no devdoc from non-static glibc
        # ${pname} & ${version} is correct due to lazy assignment
        postInstall = pkgs.glib.postInstall;
      });

      gtk3 = super.pkgsStatic.gtk3.override {
        trackerSupport = false;
        cupsSupport = false;
        withGtkDoc = false;

        # nativeBuildInputs
        inherit (pkgs) gettext gobject-introspection makeWrapper meson ninja
        pkg-config python3 sassc docbook_xml_dtd_43 docbook-xsl-nons gtk-doc libxml2;
      };

      qemu = ((super.pkgsStatic.qemu.override {
        alsaSupport = false;
        spiceSupport = false;
        sdlSupport = false;
        smartcardSupport = false;
        gtkSupport = false;
        pulseSupport = false;

        # nativeBuildInputs
        makeWrapper = pkgs.makeWrapper;
        python = pkgs.python3;
        pkg-config = pkgs.pkg-config;
        flex = pkgs.flex;
        bison = pkgs.bison;
        meson = pkgs.meson;
        ninja = pkgs.ninja;
        perl = pkgs.perl;
      }).overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs ++ [
          pkgs.binutils
          # perl as nativeBuildInputs has been added in nixpkgs master
          # while it is backported to nixpkgs 21.11 (nixos 21.11).
          # If without perl as nativeBuildInputs,
          # ./scripts/shaderinclude.pl can not be patchShebangs'ed.
          pkgs.perl # without it cannot patchShebangs
        ];
        # qemu-6.1.1 has contained sigrtminmax patch, can not be patched again
        patches = builtins.filter (
          x: ! super.lib.hasSuffix "sigrtminmax.patch" x
        ) old.patches;
      })).overrideDerivation (old: let
        # qemu configure uses "--static" instead of standard "--disable-shared" and "--enable-static"
        configureFlags_no_DS = super.lib.lists.remove "--disable-shared" old.configureFlags;
        configureFlags_no_DS_no_ES = super.lib.lists.remove "--enable-static" configureFlags_no_DS;
      in {
        configureFlags = configureFlags_no_DS_no_ES ++ [
          "--static"
          # "--target-list-exclude="
          "--target-list=x86_64-softmmu"
        ];
      });
    })];
  };
in
{
  inherit (mypkgs.pkgsStatic.pkgsCross.riscv64) qemu;
}
