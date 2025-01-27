#MC # Test for cachixPackage
#MC
#MC To run the test:
#MC
#MC ```bash
#MC # run with nix-build sandbox
#MC nix-build test.nix
#MC # run without nix-build sandbox
#MC nix-build test.nix --no-sandbox
#MC ```
let
  pkgs = import <nixpkgs> {};
  cachixPackage = import ./cachix-package.nix {inherit (pkgs) cachix stdenv writeShellScript;};
in cachixPackage {
  pkg = pkgs.hello;
  sha256 = "01vm275n169r0ly8ywgq0shgk8lrzg79d1aarshwybwxwffj4q0q";
  cachix_dhall = /home/xieby1/Gist/Config/cachix.dhall;
  cachix_name = "xieby1";
}
