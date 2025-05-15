{ config, lib, ... }:
let
  cfg = config.devmods.android;
in
{
  config = lib.mkIf cfg.enable {
    # TODO put this under `devmods.android` namespace?
    packages = {
      sync-android-build-files =
        pkgs:
        pkgs.writers.writePython3Bin "sync-android-build-files" { } (
          builtins.readFile ./sync_android_build_files.py
        );
    };
  };
}
