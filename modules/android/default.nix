{
  lib,
  config,
  ...
}:
let
  cfg = config.devmods.android;
in
{
  imports = [
    ./options.nix
    ./packages.nix
    ./devShell.nix
  ];

  config = lib.mkIf cfg.enable {
    devmods.common.allowUnfree = [ true ];
    devmods.languages.java.enable = true; # Just use defautl java language package.
    nixpkgs.config = {
      android_sdk.accept_license = true;
    };
  };
}
