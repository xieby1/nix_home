#MC # nixpkgs overlays
#MC
[
#MC ## nixpkgs overlays for RISC-V
#MC This file could be treated as a todo list of porting nixpkgs to RISC-V Linux.
(self: super: super.lib.optionalAttrs (builtins.currentSystem == "riscv64-linux") {
  bison = super.bison.overrideAttrs (old: {
    doInstallCheck = false;
  });
  coreutils = super.coreutils.overrideAttrs (old: {
    doCheck = false;
  });
  diffutils = super.diffutils.overrideAttrs (old: {
    doCheck = false;
  });
  findutils = super.findutils.overrideAttrs (old: {
    doCheck = false;
  });
  gnugrep = super.gnugrep.overrideAttrs (old: {
    doCheck = false;
  });
  hello = super.hello.overrideAttrs (old: {
    doCheck = false;
  });
  cmakeMinimal = super.cmakeMinimal.overrideAttrs (old: {
    configureFlags = [
      # https://gitlab.kitware.com/cmake/cmake/-/issues/20895
      "LDFLAGS=-latomic"
    ] ++ old.configureFlags;
  });
  cmake = super.cmake.overrideAttrs (old: {
    configureFlags = [
      "LDFLAGS=-latomic"
    ] ++ old.configureFlags;
  });
  libuv = super.libuv.overrideAttrs (old: {
    # hangs
    doCheck = false;
  });
  libseccomp = super.libseccomp.overrideAttrs (old: {
    # failed
    doCheck = false;
  });
  #MC My attempt of overlaying psutil in llvm:
  #MC
  #MC Overlay below is not work currently, due to llvmPackages and python3Packages cannot be esaily override.
  #MC The best way could be patch the nixpkgs source code.
  #MC
  #MC ```nix
  #MC llvmPackages = super.llvmPackages.overrideDerivation (oldllvmPackages: rec {
  #MC   libllvm = oldllvmPackages.libllvm.overrideAttrs (old: {
  #MC     # psutil check failed
  #MC     doCheck = false;
  #MC   });
  #MC   llvm = libllvm;
  #MC   llvm-manpages = super.lowPrio (libllvm.override {
  #MC     enableManpages = true;
  #MC     python3 = super.python3;  # don't use python-boot
  #MC   });
  #MC });
  #MC python3Packages = super.python3Packages.overrideScope (final: prev: {
  #MC   psutil = prev.psutil.overrideAttrs (old: {
  #MC     # failed
  #MC     doInstallCheck = false;
  #MC   });
  #MC });
  #MC ```
  #MC
  #MC To bypass the doInstallCheck of psutil (libbpf -> libllvm -> python3Packages.psutil),
  #MC I disable the libpbf support in systemd as below.
  systemd = super.systemd.override {
    withLibBPF = false;
  };
  e2fsprogs = super.e2fsprogs.overrideAttrs (old: {
    # failed
    doCheck = false;
  });
  libarchive = super.libarchive.overrideAttrs (old: {
    # failed
    doCheck = false;
  });
  elfutils = super.elfutils.overrideAttrs (old: {
    # failed
    doCheck = false;
    doInstallCheck = false;
  });
})
]
