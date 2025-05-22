{ config, lib, ... }:
let
  cfg = config.devModules.flutter;
in
{
  config.devShell = lib.mkIf cfg.enable (
    pkgs:
    let
      # jdkPackage = pkgs."jdk${config.devModules.languages.java.version}";

      # Use `dm-jdk` from config.devModules.languages.java

      # We need to modify this because flutter annoyingly checks for jdk on
      # installed Anddroid studio first, before considering JAVA_HOME.  So typical method
      # of setting JAVA_HOME with a nixpkgs jdk won't prevent flutter from using jdk from
      # local Android Studio installation.
      #
      # Hence, we need to override the "jdk-dir" setting.
      flutterSettingsFile = pkgs.writeTextFile {
        name = "flutter-settings.json";
        text = ''
          {
            "jdk-dir": "${pkgs.dm-jdk.home}"
          }
        '';
      };
      # # Patch flutter 3.29, the current version in nixpkgs.
      # # See: https://github.com/NixOS/nixpkgs/issues/395096#issuecomment-2850983875
      # patchedFlutter = pkgs.flutter.override (prev: rec {
      #   flutter = prev.flutter.overrideAttrs (prevAttrs: {
      #     patches = prevAttrs.patches ++ [
      #       # This patch is needed to avoid the Kotlin Gradle plugin writing to the store.
      #       (pkgs.writeText "kotlin-fix.patch" ''
      #         --- a/packages/flutter_tools/gradle/build.gradle.kts
      #         +++ b/packages/flutter_tools/gradle/build.gradle.kts
      #         @@ -4,6 +4,8 @@

      #          import org.jetbrains.kotlin.gradle.dsl.JvmTarget

      #         +gradle.startParameter.projectCacheDir = layout.buildDirectory.dir("cache").get().asFile
      #         +
      #          plugins {
      #              `java-gradle-plugin`
      #              groovy
      #       '')
      #     ];
      #     passthru = prevAttrs.passthru // {
      #       sdk = flutter;
      #     };
      #   });
      # });
      patchedFlutter = pkgs.flutter;

    in

    {
      packages = [
        patchedFlutter
      ];

      env = {
        FLUTTER_ROOT = "${patchedFlutter}";
        DART_ROOT = "${patchedFlutter}/bin/cache/dart-sdk";
      };

      shellHook = ''
        # Create a symlink to the settings file in the home directory
        #
        # Need this beccause flutter will priporitize using the same java version as Android Studio if it exists.
        # Only way to not look at Android Studio is to explicity set jdk-dir.
        # mkdir -p $HOME/.config/flutter
        ln -sf ${flutterSettingsFile} $HOME/.config/flutter/settings
      '';
    }
  );
}
