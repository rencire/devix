{ config, lib, ... }:
let
  cfg = config.devmods.profiles.flutter-dev-env;
in
{
  # TODO
  # options:
  # - androidDir  This is used to execute scripts to fix broken flutter from nixpkgs for android api 35.
  #
  # Notes
  # Can we reuse android-dev-env profile? We only need to add flutter, and other profiles
  #
  #
  config = lib.mkIf cfg.enable {
    devShell = pkgs: {
      packages = with pkgs; [
        # TODO move these to own module
        # For macos/ios
        (xcodeenv.composeXcodeWrapper { versions = [ "16.3" ]; })
        cocoapods
        google-chrome
      ];
      env = {
        # Can't use chromium unfortunately on darwin, so resort to google-chrome
        CHROME_EXECUTABLE = lib.getExe pkgs.google-chrome;
      };

      shellHook = ''
        # Need to unset below variables so that they aren't bound to outdated SDKs.
        # Found I needed to do this in order to properly read the system xcode app.
        unset DEVELOPER_DIR
        unset SDKROOT
      '';
    };
  };

}
