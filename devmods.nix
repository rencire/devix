{
  config,
  lib,
  # pkgs,
  ...
}:
let
  cfg = config.devmods.common;
in
{
  imports = [
    # TODO consider using some flakelight utils (e.g. autoload folders)
    ./modules/languages/java.nix
    ./modules/gradle/default.nix
    ./modules/android/default.nix
    ./modules/flutter/default.nix
  ];

  options.devmods.common.allowUnfree = lib.mkOption {
    type = lib.types.listOf lib.types.bool;
    default = [ ];
    description = "Modules that want to enable nixpkgs.config.allowUnfree.";
  };

  config.nixpkgs.config.allowUnfree = builtins.any (x: x) cfg.allowUnfree;
}
