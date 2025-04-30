{
  config,
  lib,
  ...
}:

let
  cfg = config.devmods.flutter;
in
{
  options.devmods.flutter = {
    enable = lib.mkEnableOption "Module for setting up flutter";
  };
  config = lib.mkIf cfg.enable {
    devmods.common.allowUnfree = [ true ];
    # devmods.languages.java.package = lib.mkForce pkgs.jdk17; # should override any other module
    nixpkgs.config = {
      allowUnfree = lib.mkForce true;
    };
    devShell = pkgs: {
      packages = with pkgs; [
        flutter327
        # For macos/ios
        (xcodeenv.composeXcodeWrapper { versions = [ "16.3" ]; })
        cocoapods
        google-chrome
      ];

      env = with pkgs; {
        FLUTTER_ROOT = "${flutter327}";
        DART_ROOT = "${flutter327}/bin/cache/dart-sdk";
        # Can't use chromium unfortunately on darwin
        CHROME_EXECUTABLE = lib.getExe pkgs.google-chrome;
      };

      shellHook = ''
        # Need to unset below variables so that they aren't bound to outdated SDKs.
        # Found I needed to do this in order to properly read the system xcode app.
        unset DEVELOPER_DIR
        unset SDKROOT

        # Create a symlink to the settings file in the home directory
        # 
        # Need this beccause flutter will priporitize using the same java version as Android Studio if it exists.
        # Only way to not look at Android Studio is to explicity set jdk-dir. 
        # mkdir -p $HOME/.config/flutter
        # ln -sf ${pkgs.writeTextFile "flutter-settings.json" ''
          #   {
          #     "jdk-dir": "test123/fdsf/sdf/"
          #   }
          # ''} $HOME/.config/flutter/settings
      '';
    };
  };
}
