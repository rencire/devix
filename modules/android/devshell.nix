{ config, lib, ... }:
let
  cfg = config.devmods.android;

  defaultPreset = {
    compileSdkVersion = "";
    platformVersions = [ "latest" ];
  };

  allPresets = {
    "api-level-34" = {
      androidGradlePluginVersion = "8.6.0";
      compileSdkVersion = "34";
      platformVersions = [ "34" ];
      buildToolsVersions = [ "34.0.0" ];
      cmakeVersions = [ "3.22.1" ];
      ndkVersions = [
        "26.3.11579264"
      ];
      # TODO
      # This value should override devmods.gradle.version
      # Note: do we want to maybe move this "preset" into a different module, like an "integrations" module?
      gradleVersion = "8.8";
      # TODO
      # This value should override devmods.languages.java.version
      # Note: do we want to maybe move this "preset" into a different module, like an "integrations" module?
      jdkVersion = "17";
    };
    "test" = {
      androidGradlePluginVersion = "9.9.9";
      compileSdkVersion = "99";
      platformVersions = [ "99" ];
    };
    # "latest" = {
    #   androidGradlePluginVersion = "";
    #   compileSdkVersion = "";
    #   platformVersions = [ "latest" ];
    #   buildToolsVersions = [ "latest" ];
    #   cmakeVersions = [ "3.31.6" ]; # TODO check if this takes in "latest" string
    #   ndkVersions = [ "26.1.10909125" ]; # TODO check if this takes in "latest" string
    # };
  };

  selectedPresetsMap = lib.filterAttrs (name: _: lib.elem name cfg.presets) allPresets;

  # Custom merge function that takes in a list of sets
  customMerge =
    mergeStrategy: sets:
    # Start by folding through all the sets, progressively merging them
    lib.foldAttrs (
      name: _value: result:
      let
        # Get the type of the attribute (use config.myModule.types or default to lib.types.str)
        attrType = lib.getAttr name config.myModule.types or lib.types.str;

        # Collect the values of the current attribute from all sets
        values = lib.map (set: lib.getAttr name set null) sets;

        # Apply the mergeStrategy to all the values of this attribute
        mergedValue = lib.fold (value1: value2: mergeStrategy name value1 value2 attrType) values;
      in
      lib.updateAttr name mergedValue result
    ) (lib.head sets) (lib.tail sets);

  getList =
    attrName: presets: defaultPreset:
    let
      values = lib.filter (x: x != null) (
        map (preset: if presets.${preset} ? ${attrName} then presets.${preset}.${attrName} else null) (
          builtins.attrNames presets
        )
      );
    in
    if values == [ ] then
      if defaultPreset.${attrName} then defaultPreset.${attrName} else null
    else
      lib.unique (lib.flatten values);

  # customMerge = ;

  getScalar =
    attrName: presets: defaultPreset:
    let
      values = lib.filter (x: x != null) (
        map (preset: if presets.${preset} ? ${attrName} then presets.${preset}.${attrName} else null) (
          builtins.attrNames presets
        )
      );
    in
    if values == [ ] then
      if defaultPreset.${attrName} then defaultPreset.${attrName} else null
    else
      lib.foldl' (a: b: if lib.versionOlder a b then b else a) (lib.head values) (lib.tail values);

  # getOptionValue = options: optionName:
  # Only support following option types:
  #
  # scalar options:
  # - str, enum
  #
  # composite:
  # - list option:
  #     Note: this only handles shallow lists:
  #     - listOf
  # # TODO support other composite
  # - either with any of above.
  #   - for now, we can support only "either" with scalars, or list types.
  #   - These will use getList, or getVersion
  # builtins.isString
  # let
  #   optionTypeName = options.${optionName}.type.name;
  # in
  #   builtins.elem optionTypeName ["int" "float" "str" "nonEmptyStr"]

  sdkArgs = {
    # TODO add getScalar or getList from above w/ default value
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
  # sdkArgs = {
  #   # TODO add getScalar or getList from above w/ default value
  #   cmdLineToolsVersion = cfg.cmdLineTools.version;
  #   platformVersions = cfg.platform.versions;
  #   platformToolsVersion = cfg.platformTools.version;
  #   buildToolsVersions = cfg.buildTools.versions;
  #   includeEmulator = cfg.emulator.enable;
  #   emulatorVersion = cfg.emulator.version;
  #   includeSystemImages = cfg.systemImages.enable;
  #   systemImageTypes = cfg.systemImageTypes;
  #   abiVersions = cfg.abis;
  #   cmakeVersions = cfg.cmake.versions;
  #   includeNDK = cfg.ndk.enable;
  #   ndkVersions = cfg.ndk.versions;
  #   useGoogleAPIs = cfg.googleAPIs.enable;
  #   includeSources = cfg.sources.enable;
  #   includeExtras = cfg.extras;
  #   extraLicenses = cfg.extraLicenses;
  # };
in
{
  # Set defaults here
  # config.devmods.android.compileSdk.version = lib.mkDefault (
  #   getScalar "compileSdkVersion" selectedPresetsMap defaultPreset
  # );
  # config.devmods.android.compileSdk.version = lib.mkDefault "1919";

  config.devShell = lib.mkIf cfg.enable (
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
      packages = [
        androidSdk # reference our own sdk settings
      ];

      # Environment variables
      env = with pkgs; {
        ANDROID_HOME = ANDROID_HOME;
        ANDROID_SDK_ROOT = ANDROID_HOME;
        ANDROID_NDK_ROOT = ANDROID_NDK_ROOT;

        # TODO need change "head" to use something like maxVersion to pick the appropriate version from a list:
        # maxVersion = builtins.foldl' (acc: v:
        # if lib.compareVersions v acc == 1 then v else acc
        # ) (builtins.head versions) (builtins.tail versions);
        GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/libexec/android-sdk/build-tools/${lib.head cfg.buildTools.versions}/aapt2";
        # emulator related: vulkan-loader and libGL shared libs are necessary for hardware decoding
        LD_LIBRARY_PATH = "${
          lib.makeLibraryPath [
            vulkan-loader
            libGL
          ]
        }:${ANDROID_HOME}/build-tools/${lib.head cfg.buildTools.versions}/lib64/
           :${ANDROID_NDK_ROOT}/${lib.head cfg.ndk.versions}/toolchains/llvm/prebuilt/${os}-x86_64/lib/
          :$LD_LIBRARY_PATH";
        # For now, it seems only x86_64 is available for prebuilt llvm libraries
        # TODO: fix bug where ndk.versions is an empty list
      };

      shellHook =
        let
          androidDir = if config.devmods.flutter.enable then "./android/" else ".";
        in
        ''
          set -e

          # tools is deprecated? I think it's replaced by command-line-tools? Add it here anyway
          export PATH="$PATH:$ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools"

          # Create a local properites file for Android Studio to read.
          # Haven't tested Android Studio with this, so not sure it works.

          # TODO move this into android directory
          # TODO add lgoic so we only do this if flutter is not enabled
          #   cat <<EOF > local.properties
          #   # This file was automatically generated by nix-shell.
          #   sdk.dir=$ANDROID_HOME
          #   ndk.dir=$ANDROID_NDK_ROOT
          #   EOF

          export ANDROID_USER_HOME=$(pwd)/.android
          export ANDROID_AVD_HOME=$(pwd)/.android/avd

          test -e "$ANDROID_USER_HOME" || mkdir -p "$ANDROID_USER_HOME"
          test -e "$ANDROID_AVD_HOME" || mkdir -p "$ANDROID_AVD_HOME"

          # Sync build files
          ${pkgs.sync-android-build-files}/bin/sync-android-build-files "${androidDir}" "${cfg.settings.platform.compileSdkVersion}" "${cfg.androidGradlePlugin.version}" "${pkgs.devmods.gradle-wrapper}"
          set +e
        '';
    }
  );
}
