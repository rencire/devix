{ config, lib, ... }:
let
  cfg = config.devModules.flutter;
in
{
  config.apps = lib.mkIf cfg.enable {
    flutter-init = pkgs: "${pkgs.flutter-init}/bin/flutter-init";
  };
}
