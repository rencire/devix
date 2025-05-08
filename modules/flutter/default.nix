{ config
, lib
, ...
}:

let
  cfg = config.devmods.flutter;
  jdkVersion = "17";
in
{
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

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # Allow unfree modules
      { devmods.common.allowUnfree = [ true ]; }
      # Need to set specific jdk version for flutter.
      { devmods.languages.java.version = lib.mkForce jdkVersion; }
      # Need to set buildtools version for android, for sdk 34.
      # TODO include logic to add 33.0.1 in head of list, if compileSdkVersion is 34
      # { devmods.android.buildTools.versions = [ "33.0.1" ]; }
      # Set flutter settings to ouput flake
      {
        apps = import ./apps.nix;
        packages = import ./packages.nix { androidCfg = config.devmods.android; };
        devShell = import ./devShell.nix {
          inherit jdkVersion;
          androidCfg = config.devmods.android;
        };
      }
    ]
  );
}
