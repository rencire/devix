{ jdkVersion }:
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
      patchedFlutter = pkgs.flutter327.override (prev: rec {
        flutter = prev.flutter.overrideAttrs (prevAttrs: {
          patches = prevAttrs.patches ++ [
            ./0001-add-settings-kts-tmpl.patch
            ./0001-add-build-kits-tmpl.patch
          ];
          passthru = prevAttrs.passthru // {
            sdk = flutter;
          };
        });
      });

    in

    {
      packages = with pkgs; [
        patchedFlutter
        # inputs'.self.packages.flutter-proxy
        # For macos/ios
        (xcodeenv.composeXcodeWrapper { versions = [ "16.3" ]; })
        cocoapods
        google-chrome
      ];

      env = with pkgs; {
        # FLUTTER_ROOT = "${flutter327}";
        FLUTTER_ROOT = "${patchedFlutter}";
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
