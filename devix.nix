{
  config,
  lib,
  # pkgs,
  ...
}:
let
  cfg = config.devModules.common;
in
{
  imports = [
    # Import utility functions and make them available for use as `utils` from moduleArgs
    {
      _module.args = {
        devix = {
          types = import ./types.nix { inherit lib; };
          utils = import ./utils.nix { inherit lib; };
        };
      };
    }
    # TODO consider using some flakelight utils (e.g. autoload folders)
    ./modules/languages/java/default.nix
    ./modules/gradle/default.nix
    ./modules/android/default.nix
    ./modules/flutter/default.nix
    ./profiles/android-dev-env/default.nix
    ./profiles/flutter-dev-env/default.nix
  ];

  options.devModules.common.allowUnfree = lib.mkOption {
    type = lib.types.listOf lib.types.bool;
    default = [ ];
    description = "Modules that want to enable nixpkgs.config.allowUnfree.";
  };

  # options.devModules.common.packages = lib.mkOption {
  #   type = lib.types.attrsOf lib.types.package;
  #   default = { };
  #   description = ''
  #     Shared packages from our devModules. Allows one level of namespacing.

  #   '';
  #   example = ''
  #     config.devModules.common.myNamespace.myPackage
  #   '';
  # };

  # Set nixpkgs.config.allowUnfree to true if any module declares this as true.
  config.nixpkgs.config.allowUnfree = builtins.any (x: x) cfg.allowUnfree;
}
