# Combines java, gradle, and android modules
{
  config,
  options,
  lib,
  dmUtils,
  ...
}:
let
  cfg = config.devmods.profiles.android-dev-env;
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
  basePreset = dmUtils.mkPreset 90 {
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
    "android-api-34" = dmUtils.mkPreset 100 {
      languages.java = {
        version = "17";
      };
      gradle = {
        version = "8.8";
      };
      android = {
        platform.compileSdkVersion = "from preset 3";
        platform.versions = [ "34" ];
        androidGradlePlugin.version = "8.6.0";
        buildTools.versions = [ "34.0.0" ];
        cmake.versions = [ "3.22.1" ];
        ndk.versions = [
          "26.3.11579264"
        ];
      };
    };
  };
  # Get list of selected presets specified by consumer of this profile
  selectedPresetsList = map (key: presets.${key}) cfg.presets;

  # Create override config that is intended to be set with values from consumers of this profile
  # - Remove nulls from overrideMOdules config, so that we don't override modules with null
  # - If a value is null or empty, it means the consumer did not set an override. Hence, we
  #   do not need to use the null or empty value to override the modules.
  overrideModulesCfgWithoutNulls = dmUtils.removeNullsAndEmptySets cfg.overrideModules;
  overrideModulesCfgWithPriorities = dmUtils.mkPreset consumerCfgPriority overrideModulesCfgWithoutNulls;
in
{
  options.devmods.profiles.android-dev-env = {
    enable = lib.mkEnableOption "Enable the Android development environment";
    presets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        List of presets for determining values of options for the android profile.
      '';
    };

    # Take existing modules' options and make a clone of them, with the addition
    # of making their type "nullable", with a default value of null.
    # This allows us to determine wheether an override value was specified or not
    # by the consumer.
    overrideModules = {
      android = dmUtils.makeNullableOptionsRecursive options.devmods.modules.android;
      languages.java = dmUtils.makeNullableOptionsRecursive options.devmods.modules.languages.java;
      gradle = dmUtils.makeNullableOptionsRecursive options.devmods.modules.gradle;
    };
  };

  config = lib.mkIf cfg.enable {
    devmods.modules = lib.mkMerge (
      # Override module option values from presets
      selectedPresetsList
      ++ [
        # Override module option values with  base preset option values
        basePreset
        # Override module option values with consumer-specified overrides
        overrideModulesCfgWithPriorities
      ]
    );
  };
}
