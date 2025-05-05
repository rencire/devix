{ jdkVersion, cfg }:
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
        # inputs'.self.packages.flutter-proxy
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

        # TODO
        # - If "android/app/build.gradle" exists, Update compileSdkVersion to always match version set in devmods.

        gradle_file="./android/app/build.gradle"
        echo "Attempting to sync compileSdk version in $gradle_file with flake.nix..."
        if [[ -f "$gradle_file" ]]; then
          cp "$gradle_file" "$gradle_file.bak"
          # Note: this assumes the latest android version is top
          sed -i.bak "s/\(\bcompileSdk\s*=\s*\)[0-9]\+/\1${cfg.compileSdkVersion}/" "$gradle_file"
          echo "✅ Updated compileSdkVersion reference in $gradle_file" to ${cfg.compileSdkVersion}
        else
          echo "⚠️ File not found: $gradle_file."
        fi

      '';
    };
}
