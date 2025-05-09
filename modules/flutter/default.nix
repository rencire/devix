{
  config,
  lib,
  ...
}:

let
  cfg = config.devmods.flutter;
in
{
  imports = [
    ./apps.nix
    ./packages.nix
    ./devShell.nix
  ];
  options.devmods.flutter = {
    enable = lib.mkEnableOption "Module for setting up flutter";

    compileSdkVersion = lib.mkOption {
      type = lib.types.str;
      default = "34";
      description = ''
        The version of the sdk we want to compile android app with.
        This will be set in "app/local.properties".
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    devmods = {
      # Allow unfree modules
      common.allowUnfree = [ true ];
    };
  };
}
