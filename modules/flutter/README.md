# Notes
- `compileSdkVersion` default value located in:
  - <flutter_sdk>/packages/flutter_tools/gradle/src/main/groovy/flutter.groovy
  - https://stackoverflow.com/questions/77228813/where-is-defined-flutter-ndkversion-in-build-gradle/77228907

- Had to create custom `flutter-proxy.sh` script to proxy the default `flutter create <app_name>`,
  such that when we create a new flutter project, we set to the Android SDK version declared in our
  flake.nix


# Resources
- https://ertt.ca/nix/shell-scripts/
- https://nixos.org/guides/nix-pills/20-basic-dependencies-and-hooks
- https://ryantm.github.io/nixpkgs/builders/trivial-builders/#chap-trivial-builders
