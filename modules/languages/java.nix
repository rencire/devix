{
  config,
  lib,
  dmTypes,
  ...
}:

let
  cfg = config.devmods.modules.languages.java;
in
{
  options.devmods.modules.languages.java = {
    # Option to enable or disable Java package
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Java package";
    };

    # Option to select the Java package (JDK version)
    version = lib.mkOption {
      type = lib.types.nullOr dmTypes.version;
      default = null;
      description = ''
        The Java package (JDK version) to use. You can specify versions that exist in nixpkgs.
        e.g. 17, 23
        If multiple versions are specified in the configuration, because we're using `dmTypes.version`, we
        will take the highest version of all the conflicting values.
        If no value is specified, defaults to `null` value, resulting in us using the latest `jdk` package from nixpkgs.
        If value is an empty string, behavior is undefined.
      '';
    };

    # package = lib.mkOption {
    #   type = lib.types.package;
    #   default = null;
    #   description = ''
    #     The Java package to use. You can specify versions that exist in nixpkgs.
    #     e.g. jdk17, jdk23
    #   '';
    # };
  };

  config = lib.mkIf cfg.enable {
    packages = {
      dm-jdk =
        pkgs:
        let
          jdkPackage = if cfg.version == null then pkgs.jdk else pkgs."jdk${cfg.version}";
        in
        jdkPackage;
    };
    devShell = pkgs: {
      packages = [
        pkgs.dm-jdk
      ];
      env = {
        JAVA_HOME = "${pkgs.dm-jdk.home}";
      };
    };
  };
}
