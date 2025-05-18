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
  # presets = {
  #   "android-api-34" = {
  #     languages.java = {
  #       version = "17";
  #     };
  #     gradle = {
  #       version = "8.8";
  #     };
  #     android = {
  #       # TODO Why do we need to set this? shouldn't we have mkDefault already?
  #       # Do we need to set priority for the other values as well? and also in modules.android?
  #       presets = {
  #         _priority = 100;
  #         _value = [ "api-34" ];
  #       };
  #     };
  #   };
  # };

  # selectedPresetSettingsList = map (key: presets.${key}) cfg.presets;
  # # \2 Add mkDefault and mkOverride to the settings
  # selectedPresetsListWithMkDefaultAndOverride = map dmUtils.mkDefaultLeaves selectedPresetSettingsList;

in
{
  # Re-use the option definitions from "modules.android"
  # update: this doesn't work
  # imports = [
  #   (lib.mkAliasOptionModule
  #     [ "devmods" "profiles" "android-dev-env" "android" ]
  #     [ "devmods" "modules" "android" ]
  #   )
  # ];
  options.devmods.profiles.android-dev-env = {
    enable = lib.mkEnableOption "Enable the Android development environment";
    # presets = lib.mkOption {
    #   type = lib.types.listOf lib.types.str;
    #   default = [ ];
    #   description = ''
    #     List of presets for determining values of options for the android profile.
    #   '';
    # };

    # android = lib.mkOption {
    #   type = lib.types.submodule (import ../modules/android/default.nix);
    #   default = { };
    #   description = "Android-specific configuration.";
    # };

    # android = lib.mkOption {
    #   type = lib.types.attrs;
    #   default = { };
    #   description = "Override android module's `settings` options.";
    # };

    # TODO
    # remove the "enable" option, don't allow user to set this
    android = import ../modules/android/options.nix { inherit lib dmTypes; };

    # Pass in java and gradle version if need to override
    java.version = lib.mkOption {
      type = dmTypes.version;
      default = null;
      description = "Override java module's `version` option.";
    };

    gradle.version = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Override gradle module's `version` option.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Set android option to true for this profile.
    # It
    # devmods.profiles.android-dev-env.android.enable = true;
    devmods.modules = lib.mkMerge (
      #     # Merge in settings from presets defined for this "android profile"
      #     selectedPresetsListWithMkDefaultAndOverride
      #     ++
      [
        #       # Pass in overrides for other options not set by presets
        {
          gradle = {
            enable = true;
            version = lib.optionalAttrs (lib.hasAttrByPath [ "gradle" "version" ] cfg) cfg.gradle.version;
          };
          languages.java = {
            enable = true;
            version = lib.optionalAttrs (lib.hasAttrByPath [ "java" "version" ] cfg) cfg.java.version;
          };
        }
        {
          # Always enable android since this android-dev-env profile is enabled
          # No need for `lib.recursiveUpdate`, since we are not merging nested attributes
          android = (lib.attrByPath [ "android" ] { } cfg) // {
            enable = true;
          };
        }

        # { android.platform.compileSdkVersion = lib.mkOverride 10 cfg.android.platform.compileSdkVersion; }
        # { android.platform.compileSdkVersion = lib.mkForce "manual update"; }
        # // {
        #   platform.compileSdkVersion = cfg.android.platform.compileSdkVersion;
        #   platform.versions = [ "34" ];
        #   androidGradlePlugin.version = "8.6.0";
        #   buildTools.versions = [ "34.0.0" ];
        #   cmake.versions = [ "3.22.1" ];
        #   ndk.versions = [
        #     "26.3.11579264"
        #   ];
        #   systemImageTypes = [
        #     "google_apis"
        #     "google_apis_playstore"
        #   ];
        #   abis = [
        #     "armeabi-v7a"
        #     "arm64-v8a"
        #   ];
        #   ndk.enable = true;

        # }
        # // {
        # platform.compileSdkVersion = lib.mkOverride 10 "100001";
        # }
      ]);
  };
}
