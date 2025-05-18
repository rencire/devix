# Combines java, gradle, and android modules
{
  config,
  options,
  lib,
  dmTypes,
  dmUtils,
  ...
}:
let
  cfg = config.devmods.profiles.android-dev-env;
  # Static value we set for override configuration so that
  # values can be overwritten.  Lower is higher priority, hence why
  # override values can "override" the preset values defined below.
  consumerCfgPriority = 90;
  # Base module settings we want enabled, wheneve this profile is enabled
  basePreset = dmUtils.mkPreset 100 {
    android.enable = true;
    gradle.enable = true;
    languages.java.enable = true;
  };
  # Define module settings for each preset
  presets = {
    "android-api-34" = dmUtils.mkPreset 100 {
      languages.java = {
        version = "17";
      };
      # gradle = {
      #   version = "8.8";
      # };
      #   android = {
      #     enable = true;
      #     platform.compileSdkVersion = "from preset 3";
      #     platform.versions = [ "34" ];
      #     androidGradlePlugin.version = "8.6.0";
      #     buildTools.versions = [ "34.0.0" ];
      #     cmake.versions = [ "3.22.1" ];
      #     ndk.versions = [
      #       "26.3.11579264"
      #     ];
      #     # Set android option to true for this profile.
      #     # TODO Why do we need to set this? shouldn't we have mkDefault already?
      #     # Do we need to set priority for the other values as well? and also in modules.android?
      #   };
    };
  };

  selectedPresetsList = map (key: presets.${key}) cfg.presets;
  # # \2 Add mkDefault and mkOverride to the settings

  # Note: this likely doesn't recursively update with mkMerge?
  # selectedPresetsListWithMkDefaultAndOverride = map dmUtils.mkDefaultLeaves selectedPresetSettingsList;

  # cfg that is intended to be set with values from other modules (i.e. end-user values)
  # This shou
  overrideModulesCfg = dmUtils.mkPreset consumerCfgPriority cfg.overrideModules;
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
  #
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

    # android = lib.mkOption {
    #   type = lib.types.attrs;
    #   default = { };
    #   description = "Override android module's `settings` options.";
    # };

    # TODO
    # remove the "enable" option, don't allow user to set this
    # TODO
    # use the `options.devmods.modules.android` value, instead of explicit import;

    # Pass in java and gradle version if need to override
    # java = (import ../modules/languages/java/options.nix { inherit lib; });
    #
    # languages.java.version = lib.mkOption {
    #   # type = lib.types.nullOr dmTypes.version;
    #   type = lib.types.nullOr lib.types.str;
    #   default = null;
    #   description = ''
    #     The Java package (JDK version) to use. You can specify versions that exist in nixpkgs.
    #     e.g. 17, 21, 23
    #     If multiple versions are specified in the configuration, because we're using `dmTypes.version`, we
    #     will take the highest version of all the conflicting values.
    #     If no value is specified, we will take the default `jdk` package from nixpkgs.
    #     If value is an empty string, behavior is undefined.
    #   '';
    # };
    # };
    overrideModules = {
      android = import ../modules/android/options.nix { inherit lib dmTypes; };
      # TODO test below code. if it works, replace above with it
      # android = import options.devmods.modules.android;
      languages.java.version = options.devmods.modules.languages.java.version;
      # gradle.version = options.devmods.modules.gradle.version;
    };

  };

  config = lib.mkIf cfg.enable {
    # TODO make presets override the versions? or the individual versions override presets?
    # I think we want latter, so we should manually merge the `android-dev-env.android`
    # options, with pressets?

    # devmods.profiles.android-dev-env.androide = true;
    #
    #
    # TODO
    # can we override

    # TODO figure out if we want to use null, or "default"
    # devmods.profiles.android-dev-env.java.version = lib.mkDefault null;
    # devmods.profiles.android-dev-env.java.version =
    #   if config.devmods.profiles.android-dev-env.java.version == null then
    #     # if preset available use it
    #     "17"
    #   else
    #     null;
    # # else pas in null or "latest"?
    # else
    #   # use default (or user config value?)
    #   config.devmods.profiles.android-dev-env.java.version;

    # Override devmods.profiles.java with presets
    devmods.modules = lib.mkMerge (
      # Add option values from presets
      selectedPresetsList
      ++ [
        # Add base preset option values
        basePreset
        # Add overrides
        overrideModulesCfg

        # {
        #   # gradle = {
        #   #   enable = true;
        #   #   version = lib.optionalAttrs (lib.hasAttrByPath [ "gradle" "version" ] cfg) cfg.gradle.version;
        #   # };

        #   languages.java = {
        #     enable = true;
        #     # lib.mkOverride 70 cfg.java.version;

        #     # How do i make sure above changes priority for user-set value, not default value?
        #     # Problem is, cfg.java.version is both the user value, and the default option value.
        #     # Oh what if we don't set a default?
        #   };

        # }

        # # {
        # #   languages.java.version = lib.optionalAttrs (lib.hasAttrByPath [
        # #     "java"
        # #     "version"
        # #   ] cfg) (lib.mkOverride 100 cfg.java.version);
        # # }
        # # User overrides
        # {
        #   languages.java.version =
        #     let
        #       preset_exists = true;
        #     in
        #     lib.optionalAttrs
        #       (lib.hasAttrByPath [
        #         "java"
        #         "version"
        #       ] cfg)
        #       (
        #         if cfg.java.version == null && preset_exists then
        #           "17" # placeholder for preset
        #         else
        #           cfg.java.version
        #         # lib.mkOverride 100 cfg.java.version
        #       );

        # }
        {
          android = (lib.attrByPath [ "android" ] { } cfg);
          # android = {
          #   platform.compileSdkVersion = "from manual override";
          # };
          # Always enable android since this android-dev-env profile is enabled
          # No need for `lib.recursiveUpdate`, since we are not merging nested attributes
          # android = (lib.attrByPath [ "android" ] { } cfg) // {
          #   enable = true;
          # };
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
      ]
    );
  };
}
