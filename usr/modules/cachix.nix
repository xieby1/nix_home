{ config, lib, ...}:

{
  imports = [../../modules/cachix.nix];
  config = lib.mkIf (
    (builtins.pathExists config.cachix_dhall) &&
    (config.cachix_packages != [])
  ) {
    home.activation.cachix_push = lib.hm.dag.entryAfter ["writeBoundary"] config._cachix_push;
  };
}
