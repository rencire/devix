{
  config,
  lib,
  dmTypes,
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
    version = lib.mkOption {
      type = dmTypes.version;
      default = "23";
      description = ''
        The Java package (JDK version) to use. You can specify versions that exist in nixpkgs.
        e.g. 17, 23
        If multiple versions are specified in the configuration, because we're using `dmTypes.version`, we
        will take the highest version of all the conflicting values.
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
    # packages = {
    # jdk = pkgs: pkgs."jdk${cfg.version}";
    # };
    devShell =
      pkgs:
      let
        jdkPackage = pkgs."jdk${cfg.version}";
        # jdkPackage = cfg.package;
      in
      {
        packages = [
          jdkPackage
        ];
        env = {
          JAVA_HOME = "${jdkPackage.home}";
        };
      };
  };
}
