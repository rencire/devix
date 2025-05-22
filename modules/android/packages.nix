{ config, lib, ... }:
let
  cfg = config.devModules.android;
  sdkArgs = {
    # TODO add getScalar or getList from above w/ default value
    cmdLineToolsVersion = cfg.cmdLineTools.version;
    platformVersions = cfg.platform.versions;
    platformToolsVersion = cfg.platformTools.version;
    buildToolsVersions = cfg.buildTools.versions;
    includeEmulator = cfg.emulator.enable;
    emulatorVersion = cfg.emulator.version;
    includeSystemImages = cfg.systemImages.enable;
    systemImageTypes = cfg.systemImageTypes;
    abiVersions = cfg.abis;
    cmakeVersions = cfg.cmake.versions;
    includeNDK = cfg.ndk.enable;
    ndkVersions = cfg.ndk.versions;
    useGoogleAPIs = cfg.googleAPIs.enable;
    includeSources = cfg.sources.enable;
    includeExtras = cfg.extras;
    extraLicenses = cfg.extraLicenses;
  };
in
{
  # Add the android sdk package to packages, so an be used in various places.
  config = lib.mkIf cfg.enable {
    packages = {
      # TODO instead of defining this here in packages, we should make this available
      # to the consuming profile via either an `option`, or we don't follow the nix module
      # format and simplify our modules with our own module attrset schema.
      dv-androidSdk =
        pkgs:
        let
          androidComposition = pkgs.androidenv.composeAndroidPackages sdkArgs;
        in
        androidComposition.androidsdk;
    };
  };
}
