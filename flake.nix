{
  description = "Flakelight module for setting up developer modules";
  # Use own forked nixpkgs w/ PR fix, until the PR is merged to nixpkgs master branch.
  #
  # Using fork because we want the changes on top of latest master.  Otherwise, we would simply
  # point to the PR commit on the original nixpkgs repo.
  inputs.nixpkgs.url = "github:rencire/nixpkgs/pr-412907-rebased";

  inputs.flakelight.url = "github:nix-community/flakelight";

  outputs =
    { flakelight, ... }@inputs:
    flakelight ./. {
      inherit inputs;
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
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
