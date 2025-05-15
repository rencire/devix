{ config, lib, ... }:
let
  cfg = config.devmods.android;
  types = import ./types.nix { inherit lib; };
  options = {
    enable = lib.mkEnableOption "tools for Android Development";

    settings.platform.compileSdkVersion = lib.mkOption {
      type = types.version;
      default = "";
      description = ''
        The version of android sdk version to use. This is used
        to update the version in `app/build.gradle.kts` file.
        By default, this is empty string, which means we will not update the
        version in `app/build.gradle.kts`. 
      '';
    };

    # settings.deadbeef = lib.mkOption {
    #   type = types.version;
    #   default = "latest";
    #   description = ''
    #     For testing.
    #   '';
    # };

    settings.foobar = lib.mkOption {
      type = lib.types.listOf (lib.types.either (lib.types.enum [ "latest" ]) (lib.types.str));
      default = [ "latest" ];
    };

    presets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        List of presets corresponding to specific versions of android-related
        packages to use. 
        By default, we use the last working versions to target API level 34.
      '';
    };

    # TODO create a dynamic option

    # gradle.version = lib.mkOption {
    #   type = lib.types.str;
    #   default = "";
    #   description = ''
    #     The version of gradle to use.
    #     By default, this is empty string, which means we will not override
    #     `devmods.gradle.version`.
    #   '';
    # };

    # TODO move each option to `settings` above

    androidGradlePlugin.version = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        The version of android gradle plugin to use. This is used
        to update the version in `settings.gradle.kts` file.
        By default, this is empty string, which means we will not update the
        version in `settings.gradle.kts`. 
      '';
    };

    cmdLineTools.version = lib.mkOption {
      type = lib.types.either (lib.types.enum [ "latest" ]) lib.types.str;
      default = "latest";
      description = ''
        The version of the Android command line tools to install.
        By default, latest version from nixpkgs is installed.
      '';
    };

    platform.versions = lib.mkOption {
      type = lib.types.listOf (lib.types.either (lib.types.enum [ "latest" ]) (lib.types.str));
      default = [ "latest" ];
      description = ''
        The Android platform versions to install.
        By default, latest version from nixpkgs is installed.
      '';
    };

    platformTools.version = lib.mkOption {
      type = lib.types.either (lib.types.enum [ "latest" ]) lib.types.str;
      default = "latest";
      description = ''
        The version of the Android platform tools to install.
        By default, latest version from nixpkgs is installed.
      '';
    };

    buildTools.versions = lib.mkOption {
      type = lib.types.listOf (lib.types.either (lib.types.enum [ "latest" ]) (lib.types.str));
      default = [
        "latest"
      ];
      description = ''
        The version of the Android build tools to install.
        By default, latest version from nixpkgs is installed.
      '';
    };

    emulator.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to include the Android Emulator.
        By default, the emulator is included.
      '';
    };

    emulator.version = lib.mkOption {
      type = lib.types.either (lib.types.enum [ "latest" ]) (lib.types.str);
      default = "35.6.2";
      description = ''
        The version of the Android Emulator to install.
        By default, version 35.6.2 is installed.
      '';
    };

    systemImages.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to include the Android system images.
        By default, the system images are included.
      '';
    };

    systemImageTypes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "google_apis_playstore" ];
      description = ''
        The Android system image types to install.
        By default, the google_apis_playstore system image is installed.
      '';
    };

    abis = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "arm64-v8a"
        "x86_64"
      ];
      description = ''
        The Android ABIs to install.
        By default, the arm64-v8a and x86_64 ABIs are installed.
      '';
    };

    cmake.versions = lib.mkOption {
      type = lib.types.listOf (lib.types.either (lib.types.enum [ "latest" ]) (lib.types.str));
      # TODO figure out if newer version also works
      default = [ "3.31.6" ];
      description = ''
        The CMake versions to install for Android.
        By default, version 3.31.6 is installed.
      '';
    };

    ndk.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to include the Android NDK (Native Development Kit).
        By default, the NDK is included.
      '';
    };

    ndk.versions = lib.mkOption {
      type = lib.types.listOf (lib.types.either (lib.types.enum [ "latest" ]) (lib.types.str));
      # TODO figure out if newer version also works
      default = [ "26.1.10909125" ];
      description = ''
        The version of the Android NDK (Native Development Kit) to install.
        By default, version 26.1.10909125 is installed.
      '';
    };

    googleAPIs.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to use the Google APIs.
        By default, the Google APIs are used.
      '';
    };

    sources.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to include the Android sources.
        By default, the sources are not included.
      '';
    };

    extras = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "extras;google;gcm" ];
      description = ''
        The Android extras to install.
        By default, the Google Cloud Messaging (GCM) extra is installed.
      '';
    };

    extraLicenses = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "android-sdk-preview-license"
        "android-googletv-license"
        "android-sdk-arm-dbt-license"
        "google-gdk-license"
        "intel-android-extra-license"
        "intel-android-sysimage-license"
        "mips-android-sysimage-license"
      ];
      description = ''
        The additional Android licenses to accept.
        By default, several standard licenses are accepted.
      '';
    };
  };

  # TODO Create abstraction for applying "presets" to modules.
  # This can be generalized beyond this `android` module to modules in general.
  #
  # Note:
  # - Conflicting list Values defined in preset map rom are all appened to a final list, while conflicting
  #   scalar values are merged into a single oldest version.  (See `version` type in `types.nix`).
  # - All default values defined in `options` get replaced with preset values.
  # - User-provided values have highest priority, and will override all.
  presets = {
    "api-34" = {
      platform.compileSdkVersion = "34";
    };
    "b" = {
      deadbeef = "1.1.2";
      foobar = [
        "2.0"
      ];
    };
    "c" = {
      deadbeef = "2.0.1";
    };
  };

  # Returns list of preset attributes from preset names that are specified by the user
  selectedPresets = map (key: presets.${key}) cfg.presets;

  mkDefaultLeaves =
    attrs:
    # Recursively adds "mkDefault" to all leaf nodes in attrSet, for each preset.
    # This is so we can support nested options.
    lib.mapAttrs (k: v: if builtins.isAttrs v then mkDefaultLeaves v else lib.mkDefault v) attrs;

  selectedDeadbeefPresetsWithDefault = map mkDefaultLeaves selectedPresets;
in
{
  options.devmods.android = options;
  # Apply attributes from selected presets
  config.devmods.android.settings = lib.mkMerge selectedDeadbeefPresetsWithDefault;
}
