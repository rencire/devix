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
      flakelightModule = ./devix.nix;
      devShell = {
        packages = pkgs: [ pkgs.ruff ];
      };
      templates = rec {
        minimal = {
          path = ./templates/minimal;
          description = "Flake for creating a minimal devix setup";
        };
        flutter = {
          path = ./templates/flutter;
          description = "Flake for creating a minimal flutter development setup";
        };
        default = minimal;
      };
      formatters = {
        "*.py" = "ruff format";
      };
    };
}
