# Combines java, gradle, and android modules
{
  config,
  lib,
  dmTypes,
  dmUtils,
  ...
}:
let
  cfg = config.devmods.profiles.android;
  presets = {
    "android-api-34" = {
      modules.languages.java.version = "17";
      modules.gradle.version = "8.8";
      modules.android.presets = [ "api-34" ];
    };
    "android-api-35" = {

    };
  };

  selectedPresetSettingsList = map (key: presets.${key}) cfg.presets;
  # \2 Add mkDefault and mkOverride to the settings
  selectedPresetsListWithMkDefaultAndOverride = map dmUtils.mkDefaultLeaves selectedPresetSettingsList;
in
{
  options.profiles.android = {
    enable = lib.mkEnableOption "Enable the Android development environment";
    presets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        List of presets for determining values of options for the android profile.
      '';
    };

    android.presets = lib.mkOption {
      type = lib.types.attrs;
      default = [ ];
      description = "Override android module's `presets` options.";
    };

    android.settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Override android module's `settings` options.";
    };

    # Pass in java and gradle version if need to override
    java.version = lib.mkOption {
      type = dmTypes.version;
      description = "Override java module's `version` option.";
    };

    gradle.version = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Override gradle module's `version` option.";
    };
  };

  config = lib.mkIf cfg.enable {
    # TODO refacotr existing "modules" to have "modules" in prefix namespace.
    # e.g.  "devmods.modules.<module_name>"
    devmods = lib.mkMerge selectedPresetsListWithMkDefaultAndOverride;
  };
}
