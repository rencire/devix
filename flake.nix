{
  description = "Flakelight module for setting up developer modules";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flakelight.url = "github:nix-community/flakelight";

  outputs =
    { flakelight, ... }@inputs:
    flakelight ./. {
      inherit inputs;
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      imports = [ flakelight.flakelightModules.flakelightModule ];
      flakelightModule = ./devmods.nix;
      devShell = {
        packages = pkgs: [ pkgs.ruff ];
      };
      formatters = {
        "*.py" = "ruff format";
      };
    };
}
