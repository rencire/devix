{
  description = "Test flutter development environment";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.devix.url = "github:rencire/devix";
  outputs =
    { devix, ... }@inputs:
    devix ./. {
      inherit inputs;
      systems = [
        # Add systems you're setting this developer environment for.
        "aarch64-darwin"
        "x86_64-linux"
      ];
      devProfiles = {
        # Add dev profile configuration here
        flutter-dev-env = {
          enable = true;
          android = {
            enable = true;
            # Only this preset is supported as of now
            presets = [ "android-api-34" ];
            # In addition to presets, can optionally can override the android, gradle, and java modules
            # See options in modules/android, modules/gradle, modules/languages/java folders.
            # overrideModules = {
            #   android = {
            #   }
            # }
          };
        };
      };
    };
}
