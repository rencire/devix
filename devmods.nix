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
    # Import utility functions and make them available for use as `utils` from moduleArgs
    {
      _module.args = {
        dmTypes = import ./types.nix { inherit lib; };
        dmUtils = import ./utils.nix { inherit lib; };
      };
    }
    # TODO consider using some flakelight utils (e.g. autoload folders)
    ./modules/languages/java.nix
    ./modules/gradle/default.nix
    ./modules/android/default.nix
    ./modules/flutter/default.nix
    ./profiles/android-dev-env.nix
  ];

  options.devmods.common.allowUnfree = lib.mkOption {
    type = lib.types.listOf lib.types.bool;
    default = [ ];
    description = "Modules that want to enable nixpkgs.config.allowUnfree.";
  };

  config.nixpkgs.config.allowUnfree = builtins.any (x: x) cfg.allowUnfree;
}
