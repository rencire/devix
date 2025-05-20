{ config, lib, ... }:
let
  cfg = config.devModules.flutter;
  # TODO consider setting `androidCfg.compileSdk.version` and `pkgs.devModules.gradle-wrapper`
  # as options available to this module, so that this module is more encapsulated.
  androidCfg = config.devModules.android;
in
{
  config.packages = lib.mkIf cfg.enable {
    flutter-init =
      pkgs:
      pkgs.writeShellApplication {
        name = "flutter-init";
        runtimeInputs = with pkgs; [
          flutter
        ];
        text = ''
          #!/usr/bin/env bash
          # 1) Create flutter initial project files
          flutter create .
          # 2) Update versions in files
          # TODO: double check the nsamespace devModules for `pkgs`. I dont think we can use this until
          # we verify many other packages  can add to this samee namepsace.
          ${pkgs.sync-android-build-files}/bin/sync-android-build-files "./android" "${androidCfg.compileSdk.version}" "${androidCfg.androidGradlePlugin.version}" "${pkgs.devModules.gradle-wrapper}"
        '';
      };
  };
}
