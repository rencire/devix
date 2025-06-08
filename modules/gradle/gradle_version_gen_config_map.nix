{ pkgs, ... }:
{
  # TODO see if we can reference these from nixpkgs, instead of copying them manually here
  # See: pkgs/development/tools/build-managers/grade/default.nix in nixpkgs repo.
  "8.14.1" = {
    version = "8.14.1";
    hash = "sha256-hFlSqdavp4PbcLs7Dv+q5FrlVCyiu3kpYZ6K9Jy2NM8=";
    defaultJava = pkgs.jdk21;
  };
  "8.8" = {
    version = "8.8";
    hash = "sha256-pLQVhgH4Y2ze6rCb12r7ZAAwu1sUSq/iYaXorwJ9xhI=";
    defaultJava = pkgs.jdk17;
  };
}
