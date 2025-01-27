# TODO: 7z need dynamical link 7z.so
#   but static compilation prevents this behavior?
{pkgs ? import <nixpkgs> {}}:
let cross = import /home/xieby1/Codes/nix-zig-stdenv {
  inherit pkgs;
  target = "x86_64-unknown-linux-musl";
};
in
cross.pkgs.p7zip.overrideAttrs (old: {
  postPatch = old.postPatch + ''
    sed -i '/CC=/d' makefile.machine
    sed -i '/CXX=/d' makefile.machine
  '';
})
