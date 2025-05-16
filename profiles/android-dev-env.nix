# Combines java, gradle, and android modules
{
  config,
  lib,
  dmTypes,
  dmUtils,
  ...
}:
let
  cfg = config.devmods.profiles.android-dev-env;
  presets = {
    "android-api-34" = {
      languages.java = {
        version = "17";
      };
      gradle = {
        version = "8.8";
      };
      android = {
        # TODO Why do we need to set this? shouldn't we have mkDefault already?
        # Do we need to set priority for the other values as well? and also in modules.android?
        presets = {
          _priority = 100;
          _value = [ "api-34" ];
        };
      };
    };
  };

  selectedPresetSettingsList = map (key: presets.${key}) cfg.presets;
  # \2 Add mkDefault and mkOverride to the settings
  selectedPresetsListWithMkDefaultAndOverride = map dmUtils.mkDefaultLeaves selectedPresetSettingsList;

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

    # android = lib.mkOption {
    #   type = lib.types.submodule (import ../modules/android/default.nix);
    #   default = { };
    #   description = "Android-specific configuration.";
    # };

    android.presets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Override android module's `presets` options.";
    };

    android.settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Override android module's `settings` options.";
    };

    # Pass in java and gradle version if need to override
    # java.version = lib.mkOption {
    #   type = dmTypes.version;
    #   default = null;
    #   description = "Override java module's `version` option.";
    # };

    # gradle.version = lib.mkOption {
    #   type = lib.types.nullOr lib.types.str;
    #   default = null;
    #   description = "Override gradle module's `version` option.";
    # };
  };

  config = lib.mkIf cfg.enable {
    devmods.modules = lib.mkMerge (
      #     # Merge in settings from presets defined for this "android profile"
      #     selectedPresetsListWithMkDefaultAndOverride
      #     ++
      [
        #       # Pass in overrides for other options not set by presets
        {
          gradle = {
            enable = true;
            #         #   version = lib.optionalAttrs (lib.hasAttrByPath [ "gradle" "version" ] cfg) cfg.gradle.version;
          };
          #         # languages.java = {
          #         #   enable = true;
          #         #   version = lib.optionalAttrs (lib.hasAttrByPath [ "java" "version" ] cfg) cfg.java.version;
          #         # };
          android = {
            enable = true;
            #         # TODO why does this line below feetch latest android sdk? is it not being overridden by the preset "android-api-34"?
            presets = lib.optionalAttrs (lib.hasAttrByPath [ "android" "presets" ] cfg) cfg.android.presets;
            settings = lib.optionalAttrs (lib.hasAttrByPath [ "android" "settings" ] cfg) cfg.android.settings;
          };
        }
      ]);
  };
}
