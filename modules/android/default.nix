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
    devmods.gradle = {
      enable = true; # Force enable gradle module
      # TODO set version to "8.8" if we're using preset api-level-34.
      # version = lib.mkForce cfg.gradle.version; # set version to value
    }
    # // (lib.optionalAttrs (cfg.gradle.version != "") {
    #   version = cfg.gradle.version;
    # })
    ;

    nixpkgs.config = {
      android_sdk.accept_license = true;
    };
  };
}
