{ lib
, config
, ...
}:
let
  cfg = config.devmods.android;
  sdkArgs = {
    cmdLineToolsVersion = cfg.cmdLineTools.version;
    platformVersions = cfg.platform.versions;
    platformToolsVersion = cfg.platformTools.version;
    buildToolsVersions = cfg.buildTools.versions;
    includeEmulator = cfg.emulator.enable;
    emulatorVersion = cfg.emulator.version;
    includeSystemImages = cfg.systemImages.enable;
    systemImageTypes = cfg.systemImageTypes;
    abiVersions = cfg.abis;
    cmakeVersions = cfg.cmake.versions;
    includeNDK = cfg.ndk.enable;
    ndkVersions = cfg.ndk.versions;
    useGoogleAPIs = cfg.googleAPIs.enable;
    includeSources = cfg.sources.enable;
    includeExtras = cfg.extras;
    extraLicenses = cfg.extraLicenses;
  };
in
{
  imports = [
    ./packages.nix
  ];
  options.devmods.android = {
    enable = lib.mkEnableOption "tools for Android Development";

    # gradle.version = lib.mkOption {
    # Currently only support 8.8
    # TODO add the other versions from nixpkgs.
    # type = lib.types.str;
    # default = "8.8";
    # description = ''
    # The version of gradle to se..
    # By default, version 8.8 is installed.
    # '';
    # };

    androidGradlePlugin.version = lib.mkOption {
      type = lib.types.str;
      default = ""; # last working version for flutter 3.29, and gradle 8.8
      description = ''
        The version of android gradple plugin version to use. This is used
        to update the version in `settings.gradle.kts` file.
        By default, this is empty string, which means we will not update the
        version in `settings.gradle.kts`. 
      '';
    };

    compileSdk.version = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        The version of android gradple plugin version to use. This is used
        to update the version in `app/build.gradle.kts` file.
        By default, this is empty string, which means we will not update the
        version in `app/build.gradle.kts`. 
      '';
    };

    cmdLineTools.version = lib.mkOption {
      type = lib.types.either (lib.types.enum [ "latest" ]) lib.types.str;
      default = "latest";
      description = ''
        The version of the Android command line tools to install.
      '';
    };

    platform.versions = lib.mkOption {
      type = lib.types.listOf (lib.types.either (lib.types.enum [ "latest" ]) (lib.types.str));
      default = [ "latest" ];
      description = ''
        The Android platform versions to install.
        By default, version 34 is installed.
      '';
    };

    platformTools.version = lib.mkOption {
      type = lib.types.either (lib.types.enum [ "latest" ]) lib.types.str;
      default = "latest";
      description = ''
        The version of the Android platform tools to install.
      '';
    };

    buildTools.versions = lib.mkOption {
      type = lib.types.listOf (lib.types.either (lib.types.enum [ "latest" ]) (lib.types.str));
      default = [
        "latest"
      ];
      description = ''
        The version of the Android build tools to install.
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

  config = lib.mkIf cfg.enable {
    devmods.common.allowUnfree = [ true ];
    devmods.languages.java.enable = true; # Just use defautl java language package.
    nixpkgs.config = {
      android_sdk.accept_license = true;
    };
    devShell = import ./devshell.nix { inherit sdkArgs cfg; };
  };
}
