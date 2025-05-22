{
  description = "Test flutter development environment";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.devix.url = "github:rencire/devix";
  outputs =
    { devix, ... }@inputs:
    devix ./. {
      inherit inputs;
      systems = [
        "aarch64-darwin"
      ];
      devProfiles = {
        # Add dev profile configuration here
      };
      # Add rest of nix flake configuration below (specifically flakelight)
      devShell = pkgs: {
        env = { };
        shellHook = "";
      };
    };
}
