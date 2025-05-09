{ config, lib, ... }:
let
  cfg = config.devmods.flutter;
in
{
  config.apps = lib.mkIf cfg.enable {
    flutter-init = pkgs: "${pkgs.flutter-init}/bin/flutter-init";
  };
}
