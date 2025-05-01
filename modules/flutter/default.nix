{
  config,
  lib,
  ...
}:

let
  cfg = config.devmods.flutter;
  jdkVersion = "17";
in
{
  options.devmods.flutter = {
    enable = lib.mkEnableOption "Module for setting up flutter";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # Allow unfree modules
      { devmods.common.allowUnfree = [ true ]; }
      # Need to set specific jdk version for flutter.
      { devmods.languages.java.version = lib.mkForce jdkVersion; }
      # Need to set buildtools version for android, for sdk 34.
      { devmods.android.buildTools.version = [ "33.0.1" ]; }
      # Set flutter settings to ouput flake
      {
        devShell =
          pkgs:
          let
            jdkPackage = pkgs."jdk${jdkVersion}";
            flutterSettingsFile = pkgs.writeTextFile {
              name = "flutter-settings.json";
              text = ''
                {
                  "jdk-dir": "${jdkPackage.home}"
                }
              '';
            };
          in

          {
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
              # Can't use chromium unfortunately on darwin, so resort to google-chrome
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
              ln -sf ${flutterSettingsFile} $HOME/.config/flutter/settings
            '';
          };
      }
    ]
  );
}
