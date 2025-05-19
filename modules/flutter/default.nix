{
  config,
  lib,
  ...
}:

let
  cfg = config.devModules.flutter;
in
{
  imports = [
    ./apps.nix
    ./packages.nix
    ./devShell.nix
  ];
  options.devModules.flutter = {
    enable = lib.mkEnableOption "Module for setting up flutter";
  };

  config = lib.mkIf cfg.enable {
    devModules = {
      # Allow unfree modules
      common.allowUnfree = [ true ];
    };
  };
}
