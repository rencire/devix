{
  lib,
  config,
  ...
}:
let
  cfg = config.devModules.android;
in
{
  imports = [
    ./options.nix
    ./devShell.nix
  ];

  config = lib.mkIf cfg.enable {
    devModules.common.allowUnfree = [ true ];
    nixpkgs.config = {
      android_sdk.accept_license = true;
    };
  };
}
