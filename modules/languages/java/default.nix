{
  config,
  lib,
  ...
}:

let
  cfg = config.devmods.modules.languages.java;
in
{
  imports = [
    ./options.nix
  ];
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
