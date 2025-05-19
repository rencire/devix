{ lib, ... }:
{
  options.devModules.languages.java = {
    # Option to enable or disable Java package
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Java package";
    };

    # Option to select the Java package (JDK version)
    version = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        The Java package (JDK version) to use. You can specify versions that exist in nixpkgs.
        e.g. 17, 21, 23
        If no value is specified, we will take the default `jdk` package from nixpkgs.
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
}
