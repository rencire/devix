{ config, lib, ... }:
let
  cfg = config.devmods.android;
in
{
  config.packages = lib.mkIf cfg.enable {
    sync-android-build-files =
      pkgs:
      pkgs.writers.writePython3Bin "sync-android-build-files" { } (
        builtins.readFile ./sync_android_build_files.py
      );
  };
}
