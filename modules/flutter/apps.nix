{ config, lib, ... }:
let
  cfg = config.devmods.modules.flutter;
in
{
  config.apps = lib.mkIf cfg.enable {
    flutter-init = pkgs: "${pkgs.flutter-init}/bin/flutter-init";
  };
}
