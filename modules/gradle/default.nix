{ config, lib, ... }:
let
  cfg = config.devModules.gradle;
in
{
  options.devModules.gradle = {
    enable = lib.mkEnableOption "Gradle devModule";
    version = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        The version of gradle to use.
        By default, this is empty string, which means we will use the latest version.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    packages = {
      # Use our `devModules` namespace under `packages`
      # TODO change, this, can't use `devModules` for other modules, since it conflicts. probably need to
      # resort to another method for namespace, or forego it alltogether.
      devModules =
        pkgs:
        if cfg.version == null then
          {
            gradle = pkgs.gradle;
            gradle-wrapper = pkgs.writeShellScript "gradle-wrapper" ''
              ${pkgs.gradle}/bin/gradle "$@"
            '';
          }
        else
          let
            gradleMap = import ./gradle_version_gen_config_map.nix { inherit pkgs; };
            genConfig = gradleMap."${cfg.version}";
            gradle-generated = pkgs.gradleGen genConfig;
            gradle-unwrapped = pkgs.callPackage gradle-generated { };
            devmod-gradle = pkgs.wrapGradle gradle-unwrapped null;
          in
          {
            # add our own devmod gradle under`devModules.gradle`
            gradle = devmod-gradle;
            gradle-wrapper = pkgs.writeShellScript "gradle-wrapper" ''
              # We're using the `gradle` we just defined above.
              ${devmod-gradle}/bin/gradle "$@"
            '';
          };
    };
    devShell =
      pkgs: with pkgs; {
        packages = [
          devModules.gradle
        ];
        env = {
          GRADLE_HOME = "${devModules.gradle}";
        };
      };
  };
}
