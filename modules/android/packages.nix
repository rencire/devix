{ config, lib, ... }:
let
  cfg = config.devModules.android;
in
{
  config = lib.mkIf cfg.enable {
    # TODO put this under `devModules.android` namespace?
    packages = {
      sync-android-build-files =
        pkgs:
        pkgs.writers.writePython3Bin "sync-android-build-files" { } (
          builtins.readFile ./sync_android_build_files.py
        );
    };
  };
}
