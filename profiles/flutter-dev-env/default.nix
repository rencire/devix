{
  config,
  lib,
  options,
  ...
}:
let
  cfg = config.devProfiles.flutter-dev-env;

in
{
  # TODO
  # options:
  # - androidDir  This is used to execute scripts to fix broken flutter from nixpkgs for android api 35.
  #
  # Notes
  # Can we reuse android-dev-env profile? We only need to add flutter, and other profiles

  options.devProfiles.flutter-dev-env = {
    enable = lib.mkEnableOption "Enable the Flutter development environment";

    # TODO
    # sdkVersion

    # Include the same options for android module that android-dev-env profile uses
    # We do override the projectDir option, since the default android directory for a typical
    # flutter project is at "./android", not the default of "." (from android-dev-env profile)
    android = options.devProfiles.android-dev-env // {
      projectDir = lib.mkOption {
        type = lib.types.str;
        default = "./android/";
        description = "Root directory of the android files";
      };
    };

  };
  config = lib.mkIf cfg.enable {
    # Reference values to android-dev-env from this profiles 'android-dev-env' options
    devProfiles.android-dev-env = cfg.android; # devProfiles.android-dev-env.presets = cfg.android.presets;
    # devProfiles.android-dev-env.projectDir = cfg.android.projectDir;

    # enable flutter module
    devModules.flutter.enable = true;
    # TODO this should already be anabled by android-dev-env?
    # devModules.languages.java.enable = true;
    # devShell = pkgs: {
    #   packages = with pkgs; [
    #     # TODO move these to own module
    #     # For macos/ios
    #     (xcodeenv.composeXcodeWrapper { versions = [ "16.3" ]; })
    #     cocoapods
    #     # for targeting web
    #     google-chrome
    #   ];
    #   env = {
    #     # Can't use chromium unfortunately on darwin, so resort to google-chrome
    #     CHROME_EXECUTABLE = lib.getExe pkgs.google-chrome;
    #   };

    #   shellHook = ''
    #     # Need to unset below variables so that they aren't bound to outdated SDKs.
    #     # Found I needed to do this in order to properly read the system xcode app.
    #     # TODO move this to the apple module/profile
    #     unset DEVELOPER_DIR
    #     unset SDKROOT
    #   '';
    # };
  };

}
