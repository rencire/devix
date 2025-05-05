{
  lib,
  config,
  ...
}:
let
  cfg = config.devmods.android;
  sdkArgs = {
    cmdLineToolsVersion = cfg.cmdLineTools.version;
    platformVersions = cfg.platform.versions;
    platformToolsVersion = cfg.platformTools.version;
    buildToolsVersions = cfg.buildTools.version;
    includeEmulator = cfg.emulator.enable;
    emulatorVersion = cfg.emulator.version;
    includeSystemImages = cfg.systemImages.enable;
    systemImageTypes = cfg.systemImageTypes;
    abiVersions = cfg.abis;
    cmakeVersions = cfg.cmake.version;
    includeNDK = cfg.ndk.enable;
    ndkVersions = cfg.ndk.versions;
    useGoogleAPIs = cfg.googleAPIs.enable;
    includeSources = cfg.sources.enable;
    includeExtras = cfg.extras;
    extraLicenses = cfg.extraLicenses;
  };
in
{
  options.devmods.android = {
    enable = lib.mkEnableOption "tools for Android Development";

    cmdLineTools.version = lib.mkOption {
      type = lib.types.str;
      default = "19.0";
      description = ''
        The version of the Android command line tools to install.
      '';
    };

    platform.versions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "34" ];
      description = ''
        The Android platform versions to install.
        By default, version 34 is installed.
      '';
    };

    platformTools.version = lib.mkOption {
      type = lib.types.str;
      default = "35.0.2";
      description = ''
        The version of the Android platform tools to install.
      '';
    };

    buildTools.version = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "36.0.0"
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
      type = lib.types.str;
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

    cmake.version = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      # TODO figure out if newer version also works
      default = [ "3.31.6" ];
      description = ''
        The CMake versions to install for Android.
        By default, version 3.31.6 is installed.
      '';
    };

    ndk.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to include the Android NDK (Native Development Kit).
        By default, the NDK is included.
      '';
    };

    ndk.versions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
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
    devShell =
      pkgs:
      let
        androidComposition = pkgs.androidenv.composeAndroidPackages sdkArgs;
        androidSdk = androidComposition.androidsdk;
        ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
        # NOTE: not sure why `avdmanager` is warningabout `ndk` and `nkd-bundle` both existing.
        ANDROID_NDK_ROOT = "${ANDROID_HOME}/ndk/";
        os = builtins.elemAt (builtins.split "-" pkgs.stdenv.system) 2;
      in
      {
        packages = with pkgs; [
          androidSdk # reference our own sdk settings
          gradle
        ];

        # Environment variables
        env = with pkgs; {
          ANDROID_HOME = ANDROID_HOME;
          ANDROID_SDK_ROOT = ANDROID_HOME;
          ANDROID_NDK_ROOT = ANDROID_NDK_ROOT;

          GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/libexec/android-sdk/build-tools/${lib.head cfg.buildTools.version}/aapt2";
          # emulator related: vulkan-loader and libGL shared libs are necessary for hardware decoding
          LD_LIBRARY_PATH = "${
            lib.makeLibraryPath [
              vulkan-loader
              libGL
            ]
          }:${ANDROID_HOME}/build-tools/${lib.head cfg.buildTools.version}/lib64/
           :${ANDROID_NDK_ROOT}/${lib.head cfg.ndk.versions}/toolchains/llvm/prebuilt/${os}-x86_64/lib/
          :$LD_LIBRARY_PATH";
          # For now, it seems only x86_64 is available for prebuilt llvm libraries
          # TODO: fix bug where ndk.versions is an empty list
        };

        shellHook = ''
          set -e

          # tools is deprecated? I think it's replaced by command-line-tools? Add it here anyway
          export PATH="$PATH:$ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools"

          # Create a local properites file for Android Studio to read.
          # Haven't tested Android Studio with this, so not sure it works.

          # TODO move this into android directory
          # TODO add lgoic so we only do this if flutter is not enabled
          # if [ "${toString config.devmods.flutter.enable}" = "false" ]; then
          #   cat <<EOF > local.properties
          #   # This file was automatically generated by nix-shell.
          #   sdk.dir=$ANDROID_HOME
          #   ndk.dir=$ANDROID_NDK_ROOT
          #   EOF
          # fi

          export ANDROID_USER_HOME=$(pwd)/.android
          export ANDROID_AVD_HOME=$(pwd)/.android/avd

          test -e "$ANDROID_USER_HOME" || mkdir -p "$ANDROID_USER_HOME"
          test -e "$ANDROID_AVD_HOME" || mkdir -p "$ANDROID_AVD_HOME"
          set +e
        '';
      };
  };
}
