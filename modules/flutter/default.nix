{
  config,
  lib,
  ...
}:

let
  cfg = config.devmods.modules.flutter;
in
{
  imports = [
    ./apps.nix
    ./packages.nix
    ./devShell.nix
  ];
  options.devmods.modules.flutter = {
    enable = lib.mkEnableOption "Module for setting up flutter";
  };

  config = lib.mkIf cfg.enable {
    devmods = {
      # Allow unfree modules
      common.allowUnfree = [ true ];
    };
  };
}
