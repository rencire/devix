{
  lib,
  config,
  ...
}:
let
  cfg = config.devmods.modules.android;
in
{
  imports = [
    ./options.nix
    ./packages.nix
    ./devShell.nix
  ];

  config = lib.mkIf cfg.enable {
    devmods.common.allowUnfree = [ true ];
    nixpkgs.config = {
      android_sdk.accept_license = true;
    };
  };
}
