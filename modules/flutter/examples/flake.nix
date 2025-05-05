{
  description = "Test flutter development environment";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flakelight.url = "github:accelbread/flakelight";
  inputs.devmods.url = "github:rencire/devmods";
  outputs =
    { flakelight, devmods, ... }@inputs:
    devmods ./. {
      inherit inputs;
      systems = [
        "aarch64-darwin"
      ];
      devmods = {
        android = {
          enable = true;
          platform.versions = [
            "34"
          ];
          systemImageTypes = [
            "google_apis"
            "google_apis_playstore"
          ];
          abis = [
            "armeabi-v7a"
            "arm64-v8a"
          ];
          ndk = {
            enable = true;
            # versions = [ ];
          };
        };
        flutter = {
          enable = true;
          compileSdkVersion = "34";
        };
      };
    };
}
