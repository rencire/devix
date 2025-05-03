{
  config,
  lib,
  ...
}:

let
  cfg = config.devmods.flutter;
  jdkVersion = "17";
in
{
  options.devmods.flutter = {
    enable = lib.mkEnableOption "Module for setting up flutter";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # Allow unfree modules
      { devmods.common.allowUnfree = [ true ]; }
      # Need to set specific jdk version for flutter.
      { devmods.languages.java.version = lib.mkForce jdkVersion; }
      # Need to set buildtools version for android, for sdk 34.
      { devmods.android.buildTools.version = [ "33.0.1" ]; }
      # Set flutter settings to ouput flake
      (import ./devShell.nix { inherit jdkVersion; })
    ]
  );
}
