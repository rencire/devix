{ config, lib, ... }:
let
  cfg = config.devmods.gradle;
in
{
  options.devmods.gradle = {
    enable = lib.mkEnableOption "Gradle devModule";
    version = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        The version of gradle to use. 
        By default, this is empty string, which means we will use the latest version.. 
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    packages = {
      # Use our `devmods` namespace under `packages`
      devmods =
        pkgs:
        let
          gradleMap = import ./gradle_version_gen_config_map.nix { inherit pkgs; };
          genConfig = gradleMap."${cfg.version}";
          gradle-generated = pkgs.gradleGen genConfig;
          gradle-unwrapped = pkgs.callPackage gradle-generated { };
          devmod-gradle = pkgs.wrapGradle gradle-unwrapped null;
        in
        {
          # add our own devmod gradle under`devmods.gradle`
          gradle = if cfg.version == "" then pkgs.gradle else devmod-gradle;
          gradle-wrapper = pkgs.writeShellScript "gradle-wrapper" ''
            # We're using the `gradle` we just defined above.
            ${devmod-gradle}/bin/gradle "$@"
          '';
        };
    };
    devShell =
      pkgs: with pkgs; {
        packages = [
          devmods.gradle
        ];
        env = {
          GRADLE_HOME = "${devmods.gradle}";
        };
      };
  };
}
