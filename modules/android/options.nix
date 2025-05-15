{ config, lib, ... }:
let
  cfg = config.devmods.android;
  myLib = import ./lib.nix;
  types = import ./types.nix { inherit lib; };
  options = {
    enable = lib.mkEnableOption "tools for Android Development";

    # deadbeef = lib.mkOption {
    # default = if cfg.foobar == [ "options.nix 3" ] then [ "deadbeef" ] else [ "false" ];
    # merge =
    #   loc: defs:
    #   let
    #     values = map (x: x.value) defs;
    #   in
    #   (builtins.concatStringsSep "," values);
    # };
    #
    # NOTE: issue with this solution is that this doesn't allow user to override.
    #   We simply look at all teh values and combine them.
    #
    presetAttrs.deadbeef = lib.mkOption {
      type = types.version;
      default = "latest";
      description = ''
        For testing.
      '';
    };

    presetAttrs.foobar = lib.mkOption {
      type = lib.types.listOf (lib.types.either (lib.types.enum [ "latest" ]) (lib.types.str));
      default = [ "latest" ];
      # type = lib.types.str;
      # type = lib.types.listOf lib.types.str;
      # default = mergeSets.foobar;
      # type = lib.mkOptionType {
      # name = "version";
      # default = ["latest"]
      # merge =
      #   loc: defs:
      #   let
      #     values = map (x: x.value) defs;
      #   in
      #   (builtins.concatStringsSep "," values);

    };

    presets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      # default = [ "latest" ];
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

    androidGradlePlugin.version = lib.mkOption {
      type = lib.types.str;
      # default = ""; # last working version for flutter 3.29, and gradle 8.8
      description = ''
        The version of android gradle plugin to use. This is used
        to update the version in `settings.gradle.kts` file.
        By default, this is empty string, which means we will not update the
        version in `settings.gradle.kts`. 
      '';
    };

    compileSdk.version = lib.mkOption {
      type = lib.types.str;
      # default = "";
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
  # presets = {
  #   "api-level-34" = {
  #     androidGradlePluginVersion = "8.6.0";
  #     compileSdkVersion = "34";
  #     platformVersions = [ "34" ];
  #     buildToolsVersions = [ "34.0.0" ];
  #     cmakeVersions = [ "3.22.1" ];
  #     ndkVersions = [
  #       "26.3.11579264"
  #     ];
  #     # TODO
  #     # This value should override devmods.gradle.version
  #     # Note: do we want to maybe move this "preset" into a different module, like an "integrations" module?
  #     gradleVersion = "8.8";
  #     # TODO
  #     # This value should override devmods.languages.java.version
  #     # Note: do we want to maybe move this "preset" into a different module, like an "integrations" module?
  #     jdkVersion = "17";
  #   };
  #   "test" = {
  #     androidGradlePluginVersion = "9.9.9";
  #     compileSdkVersion = "99";
  #     platformVersions = [ "99" ];
  #   };
  #   # "latest" = {
  #   #   androidGradlePluginVersion = "";
  #   #   compileSdkVersion = "";
  #   #   platformVersions = [ "latest" ];
  #   #   buildToolsVersions = [ "latest" ];
  #   #   cmakeVersions = [ "3.31.6" ]; # TODO check if this takes in "latest" string
  #   #   ndkVersions = [ "26.1.10909125" ]; # TODO check if this takes in "latest" string
  #   # };
  # };
  # # allPresets = presets // cfg.customPresets;
  # allPresets = presets;

  # selectedPresets = lib.filterAttrs (name: _: lib.elem name cfg.presets) allPresets;

  # getList =
  #   attrName: selectedPresets:
  #   let
  #     values = lib.filter (x: x != null) (
  #       map (
  #         preset:
  #         if selectedPresets.${preset} ? ${attrName} then selectedPresets.${preset}.${attrName} else null
  #       ) (builtins.attrNames selectedPresets)
  #     );
  #   in
  #   lib.unique (lib.flatten values);

  # getScalar =
  #   attrName: selectedPresets:
  #   let
  #     values = lib.filter (x: x != null) (
  #       map (
  #         preset:
  #         if selectedPresets.${preset} ? ${attrName} then selectedPresets.${preset}.${attrName} else null
  #       ) (builtins.attrNames selectedPresets)
  #     );
  #   in
  #   if values == [ ] then
  #     null
  #   else
  #     lib.foldl' (a: b: if lib.versionOlder a b then b else a) (lib.head values) (lib.tail values);

  mergeFunc =
    prefix: key: a: b:
    let
      optionType = options.${prefix}.${key}.type;
      typeString = builtins.toString optionType.name; # Convert type to string for comparison
      scalarTypeNameStrings = [
        "str"
        "int"
      ];
    in
    # TODO: if a and b are attrsets, need to recurse them. Need to pass in a prefix path also,
    # so that we can access nested options.

    # TODO: only support lists, str, and either
    # builtins.trace "Type of ${key} is: ${typeString}" typeString; # Print typeString for debugging
    # "mergeFunc";
    # "${key}"";
    # TODO use the merge
    # b;
    if typeString == "version" then
      if lib.versionOlder a b then b else a
    else if typeString == "listOf" then
      # for now ,just merge ethem all together
      a ++ b
    else
      # if typeString == "listOf" then
      #   # TODO handle other cases.
      #   # For now, we assume its a list of versionsstrings only
      #   # Use versionOlder
      # else if builtins.elem typeString scalarTypeNameStrings then
      #   # TODO create own custom type for scalar verion strings
      #   # Assume string is a version string
      #   if lib.versionOlder a b then b else a
      # else
      # Default to the newer value on the right (b)
      b;
  # if key == "foobar" then 9999 else a;
  #
  allPresets = {
    "a" = {
      foobar = "1.1.1";
    };
    "b" = {
      foobar = "1.1.2";
    };
    "c" = {
      foobar = "2.0.1";
    };
  };

  selectedPresets = map (key: allPresets.${key}) cfg.presets;

  # mergedSets = myLib.mergeListOfSets {
  #   inherit mergeFunc;
  #   prefix = "presetAttrs";
  #   attrSets = selectedPresets;
  # };

  deadbeefpresets = {
    "a" = {
      deadbeef = "1.1.1";
    };
    "b" = {
      deadbeef = "1.1.2";
    };
    "c" = {
      # deadbeef = "2.0.1";
    };
  };

  # Returns list of preset attributes
  selectedDeadbeefPresets = map (key: deadbeefpresets.${key}) cfg.presets;

  mkDefaultLeaves =
    attrs:
    # Recursively adds "mkDefault" to all leaf nodes in attrSet, for each preset.
    # This is so we can support nested options.
    lib.mapAttrs (k: v: if builtins.isAttrs v then mkDefaultLeaves v else lib.mkDefault v) attrs;

  selectedDeadbeefPresetsWithDefault = map mkDefaultLeaves selectedDeadbeefPresets;

  # TODO
  # Add "default" values if option value does not exist.
in
{
  options.devmods.android = options;
  # TODO test mergeSets
  # config.devmods.android = map (key: allPresets.${key}) cfg.presets;
  # config.devmods.android = {
  #   # foobar = lib.mkDefault "1.2.3";
  #   foobar = mergedSets.foobar;
  # };
  #
  #
  # NOTE: this works below
  # config.devmods.android.presetAttrs = mergedSets;

  config.devmods.android.presetAttrs = lib.mkMerge selectedDeadbeefPresetsWithDefault;

  # let
  # names = lib.attrNames mergedSets;
  # in
  # {
  # foobar = lib.mkDefault "1.2.3";
  # foobar = mergedSets.${lib.elemAt names 0};
  # };
  #
  # config.devmods.android = mergedSets;
  # } // mergedSets;

  # config.devmods.android = lib.mkMerge [
  # { foobar = "abc"; }
  # (lib.getAttr "${lib.elemAt cfg.presets 0}" allPresets)
  # ];
  # config.devmods.android =
  #   let
  #     selectedPresets = lib.getAttrs cfg.presets allPresets;
  #     attrValues = lib.attrValues selectedPresets;
  #   in
  #   lib.mkMerge attrValues;
  # # lib.mkMerge [
  # { foobar = lib.getAttr "foobar" (lib.getAttr "${lib.elemAt cfg.presets 0}" allPresets); }
  # { foobar = lib.getAttr "foobar" (lib.getAttr "${lib.elemAt cfg.presets 1}" allPresets); }

  # ];

  # let
  # selectedPresets = lib.getAttrs cfg.presets allPresets;
  # in
  # lib.mkMerge (lib.attrValues selectedPresets);
  # config.devmods.android = lib.mkMerge [
  # selectedPresets
  #   {
  #     # apply the values from presets here
  #     # foobar = lib.mkDefault mergeSets.foobar;
  #     foobar = "abc";
  #   }
  # { foobar = "123"; }
  # { foobar = "${lib.elemAt cfg.presets 0}"; }
  # ];
}
