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
    gradle_8_8 =
      pkgs:
      let
        gradle_8_8-generated = pkgs.gradleGen {
          version = "8.8";
          hash = "sha256-pLQVhgH4Y2ze6rCb12r7ZAAwu1sUSq/iYaXorwJ9xhI=";
          # TODO might have to change this version to jdk 17?
          defaultJava = pkgs.jdk17;
        };
        gradle_8_8-unwrapped = pkgs.callPackage gradle_8_8-generated { };
      in
      pkgs.wrapGradle gradle_8_8-unwrapped null;
    gradle-wrapper =
      { writeShellScript, gradle_8_8, ... }:
      writeShellScript "gradle-wrapper" ''
        ${gradle_8_8}/bin/gradle "$@"
      '';
  };
}
