{ config, lib, ... }:
let
  cfg = config.devModules.flutter;
  # TODO consider setting `androidCfg.compileSdk.version` and `pkgs.devModules.gradle-wrapper`
  # as options available to this module, so that this module is more encapsulated.
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
          # 2) Ask user to reload shell
          echo "Reload the nix developer shell:"
          echo "e.g. ctrl-d, then use 'nix develop'"
        '';
      };
  };
}
