# https://github.com/NixOS/nixpkgs/issues/185773
{ lib, callPackage, fetchFromGitHub, fetchurl, openssl_1_1 }:

((callPackage (import (fetchFromGitHub {
  owner = "NixOS";
  repo = "nixpkgs";
  rev = "363ef08971726937cd6a63de0efef7f8ba657b18";
  sha256 = "sha256-QRKAn5yLMyohZKsK72Vkd6HQUh3t5tDpFyI/Y7T3ASg=";
}) { }).shellinabox.override) { openssl = openssl_1_1; }).overrideAttrs
({ patches, ... }: {
  patches = patches ++ [
    # OpenSSL 1.1
    (fetchurl {
      url =
        "https://github.com/shellinabox/shellinabox/commit/c32f3d365a0848eb6b3350ec521fcd4d1d098295.patch";
      hash = "sha256-Q8otJUip1YQJb0ZSF89BjSvrCh4PQe4R7Rb7mtm33tk=";
    })
  ];
})
