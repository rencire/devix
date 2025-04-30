{
  description = "Flakelight module for setting up developer modules";
  inputs.flakelight.url = "github:nix-community/flakelight";

  outputs =
    { flakelight, ... }:
    flakelight ./. {
      imports = [ flakelight.flakelightModules.flakelightModule ];
      flakelightModule = ./devmods.nix;
    };
}
