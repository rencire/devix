{
  lib,
  config,
  dmUtils,
  dmTypes,
  ...
}:
let
  cfg = config.devmods.modules.android;
  options = import ./options.nix { inherit lib dmTypes; };

  #   presets = {
  #     "api-34" = {
  #       platform.compileSdkVersion = "34";
  #       platform.versions = [ "34" ];
  #       androidGradlePlugin.version = "8.6.0";
  #       buildTools.versions = [ "34.0.0" ];
  #       cmake.versions = [ "3.22.1" ];
  #       ndk.versions = [
  #         "26.3.11579264"
  #       ];
  #       # NOTE: do we want to maybe move this "preset" into a different module, like an "integrations" module?
  #       # gradleVersion = "8.8";
  #       # NOTE: do we want to maybe move this "preset" into a different module, like an "integrations" module?
  #       # languages.java = {
  #       #   enable = true;
  #       #   version = "17";
  #       # };
  #     };
  #     # TODO its not being passed here.
  #     "test" = {
  #       platform.compileSdkVersion = {
  #         _value = "34";
  #         _priority = 50;
  #       };
  #       platform.versions = {
  #         _value = [ "34" ];
  #         _priority = 50;
  #       };
  #       androidGradlePlugin.version = {
  #         _value = "8.6.0";
  #         _priority = 50;
  #       };
  #       buildTools.versions = {
  #         _value = [ "34.0.0" ];
  #         _priority = 50;
  #       };
  #       cmake.versions = {
  #         _value = [ "3.22.1" ];
  #         _priority = 50;
  #       };
  #       ndk.versions = {
  #         _value = [
  #           "26.3.11579264"
  #         ];
  #         _priority = 50;
  #       };
  #       # platform.compileSdkVersion = "35";
  #       # languages.java = {
  #       #   enable = true;
  #       #   version = "23";
  #       # };
  #       # Example of using _value and _priority if need mkOverride
  #       # languages.java.version = {
  #       #   _value = "23";
  #       #   _priority = 980;
  #       # };
  #     };
  #   };

  #   # Partitions list below:
  #   # [
  #   #   {
  #   #     android.settings = {
  #   #       abis = [...];
  #   #       ...
  #   #     },
  #   #     languages.java = {
  #   #       version = 9;
  #   #       ...
  #   #     },
  #   #     ...
  #   #   }
  #   #   {
  #   #     android.settings = {
  #   #       abis = [...];
  #   #       ...
  #   #     },
  #   #     languages.java = {
  #   #       version = 10;
  #   #       ...
  #   #     },
  #   #     ...
  #   #   }
  #   # ]
  #   # into two lists:
  #   # 1. [ {abis=[...];...} {abis=[...]; ...} ...]
  #   # 2. [ {version = 9; ...} {version = 10;... } ]
  #   # partitionPresetList =
  #   #   presets:
  #   #   lib.foldl'
  #   #     (acc: preset: {
  #   #       androidSettingsList =
  #   #         acc.androidSettingsList
  #   #         ++ (if lib.hasAttrByPath [ "android" "settings" ] preset then [ preset.android.settings ] else [ ]);
  #   #       languagesJavaList =
  #   #         acc.languagesJavaList
  #   #         ++ (if lib.hasAttrByPath [ "languages" "java" ] preset then [ preset.languages.java ] else [ ]);
  #   #     })
  #   #     {
  #   #       androidSettingsList = [ ];
  #   #       languagesJavaList = [ ];
  #   #     }
  #   #     presets;

  #   # \1 Returns list of preset attributes from preset names that are specified by the user
  #   selectedPresetSettingsList = map (key: presets.${key}) cfg.presets;
  #   # \2 Add mkDefault and mkOverride to the settings
  #   selectedPresetsListWithMkDefaultAndOverride = map dmUtils.mkDefaultLeaves selectedPresetSettingsList;
  #   # \3 Partition list of presets into settings for modules
  #   # partitionedPresetLists = partitionPresetList selectedPresetsListWithMkDefaultAndOverride;
  #   # androidSettingsList = partitionedPresetLists.androidSettingsList;
  #   # languagesJavaList = partitionedPresetLists.languagesJavaList;
in
{
  imports = [
    ./packages.nix
    ./devShell.nix
  ];

  options.devmods.modules.android = options;

  config = lib.mkIf cfg.enable {
    # Apply preset option values
    # TODO consider moving this preset value logic higher to the "android-dev-env" profile
    # devmods.modules.android.settings = lib.mkMerge selectedPresetsListWithMkDefaultAndOverride;
    devmods.common.allowUnfree = [ true ];
    # devmods.modules.languages.java.enable = true; # Just use defautl java language package.
    # TODO get rid of line below, this should be set in "profiles", not in module.
    # devmods.modules.gradle = {
    #   enable = true; # Force enable gradle module
    #   # TODO set version to "8.8" if we're using preset api-level-34.
    #   # version = lib.mkForce cfg.gradle.version; # set version to value
    # }
    # // (lib.optionalAttrs (cfg.gradle.version != "") {
    #   version = cfg.gradle.version;
    # })
    # ;

    nixpkgs.config = {
      android_sdk.accept_license = true;
    };
  };
}
