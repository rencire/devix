{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.devmods.languages.java;
in
{
  options.devmods.languages.java = {
    # Option to enable or disable Java package
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Java package";
    };

    # Option to select the Java package (JDK version)
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.jdk23;
      description = "The Java package (JDK version) to use. You can specify any package like pkgs.jdk17 or pkgs.jdk23.";
    };
  };

  config = lib.mkIf cfg.enable {
    devShell = {
      packages = [
        config.devmods.languages.java.package
      ];

      env = {
        JAVA_HOME = "${config.devmods.languages.java.package.home}";
      };
    };
  };
}
