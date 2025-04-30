{ config, lib, ... }:
let
  cfg = config.devmods.common;
in
{
  imports = [
    # TODO consider using some flakelight utils (e.g. autoload folders)
    ./modules/android/default.nix
    ./modules/flutter/default.nix
    ./modules/languages/java.nix
  ];

  options.devmods.common.allowUnfree = lib.mkOption {
    type = lib.types.listOf lib.types.bool;
    default = [ ];
    description = "Modules that want to enable nixpkgs.config.allowUnfree.";
  };

  config.nixpkgs.config.allowUnfree = builtins.any (x: x) cfg.allowUnfree;
}
