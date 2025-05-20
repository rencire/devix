# Combines java, gradle, and android modules
{
  config,
  options,
  lib,
  devix,
  ...
}:
let
  cfg = config.devProfiles.android-dev-env;
  androidModuleCfg = config.devModules.android;
  # Static value we set for override configuration so that
  # values can be overwritten.  Lower is higher priority, hence why
  # override values can "override" the preset values defined below.
  #
  # Notes:
  # - We start setting the preset override values at the minimum
  #   override level (i.e. 100).  This is to ensure that priority
  #   for the preset values are higher than the null priority value (default to 1000).
  # - For details on the null override priority level, see `utils.nix#mkPreset`.
  consumerCfgPriority = 80;

  # Base module settings we want enabled, wheneve this profile is enabled
  basePreset = devix.utils.mkPreset 90 {
    android.enable = true;
    gradle.enable = true;
    languages.java.enable = true;
  };
  # Define module settings for each preset
  # Consumer can set presets for common option values to pass to dependent modules.
  #
  # Note that each preset has a default override priority value applied to all values
  # in its attribute set.
  # - We can optionally modify the priority for each specific individual value also.
  #    (See: utils.nix#mkPreset)
  presets = {
    "android-api-34" = devix.utils.mkPreset 100 {
      languages.java = {
        version = "17";
      };
      gradle = {
        version = "8.8";
      };
      android = {
        platform.compileSdkVersion = "34";
        platform.versions = [ "34" ];
        androidGradlePlugin.version = "8.6.0";
        buildTools.versions = [ "34.0.0" ];
        cmake.versions = [ "3.22.1" ];
        ndk = {
          enable = true;
          versions = [
            "26.3.11579264"
          ];
        };
      };
    };
  };
  # Get list of selected presets specified by consumer of this profile
  selectedPresetsList = map (key: presets.${key}) cfg.presets;

  # Create override config that is intended to be set with values from consumers of this profile
  # - Remove nulls from overrideMOdules config, so that we don't override modules with null
  # - If a value is null or empty, it means the consumer did not set an override. Hence, we
  #   do not need to use the null or empty value to override the modules.
  overrideModulesCfgWithoutNulls = devix.utils.removeNullsAndEmptySets cfg.overrideModules;
  overrideModulesCfgWithPriorities = devix.utils.mkPreset consumerCfgPriority overrideModulesCfgWithoutNulls;
in
{
  imports = [
    ./packages.nix
  ];
  options.devProfiles.android-dev-env = {
    enable = lib.mkEnableOption "Enable the Android development environment";
    presets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        List of presets for determining values of options for the android profile.
      '';
    };
    projectDir = lib.mkOption {
      type = lib.types.str;
      default = "."; # denotes current directory
      description = ''
        Directory of android project.
      '';
    };

    # Take existing modules' options and make a clone of them, with the addition
    # of making their type "nullable", with a default value of null.
    # This allows us to determine wheether an override value was specified or not
    # by the consumer.
    overrideModules = {
      android = devix.utils.makeNullableOptionsRecursive options.devModules.android;
      languages.java = devix.utils.makeNullableOptionsRecursive options.devModules.languages.java;
      gradle = devix.utils.makeNullableOptionsRecursive options.devModules.gradle;
    };
  };

  config = lib.mkIf cfg.enable {
    devModules = lib.mkMerge (
      # Override module option values from presets
      selectedPresetsList
      ++ [
        # Override module option values with  base preset option values
        basePreset
        # Override module option values with consumer-specified overrides
        overrideModulesCfgWithPriorities
      ]
    );
    devShell = pkgs: {
      env = {
        # Patch gradle and android integration (needed for api level 34)
        # TODO need something more robust then picking the head of list to get appropriate version, if
        # list intended to have multiple versions.
        # Works for now, since mainly using preset "api level 34", which only needs buildtools version 34.0.0.
        GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${pkgs.dv-androidSdk}/libexec/android-sdk/build-tools/${lib.head androidModuleCfg.buildTools.versions}/aapt2";
      };
      shellHook = ''
        # Sync versions specified in our nix files with the settings specified in the android files
        ${pkgs.sync-android-build-files}/bin/sync-android-build-files "${cfg.projectDir}" "${androidModuleCfg.platform.compileSdkVersion}" "${androidModuleCfg.androidGradlePlugin.version}" "${pkgs.devModules.gradle-wrapper}"
      '';
    };
  };
}
