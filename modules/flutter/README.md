# Notes
- `compileSdkVersion` default value located in:
  - <flutter_sdk>/packages/flutter_tools/gradle/src/main/groovy/flutter.groovy
  - https://stackoverflow.com/questions/77228813/where-is-defined-flutter-ndkversion-in-build-gradle/77228907

- Issue w/ latest Flutter build not working:
  - Approach 1: Downgrade flutter, and modify files initialized by `flutter create`
    - Had to create custom `flutter-proxy.sh` script to proxy the default `flutter create <app_name>`,
      such that when we create a new flutter project, we set to the Android SDK version declared in our
      flake.nix
    - Also, consider patching the files themselves, like in Approach 2
  - Approach 2: Patch the kotlin gradle plugin
    - Continue using latest flutter, but patch the flutter code / template files themselves.
    - See: https://github.com/NixOS/nixpkgs/issues/395096#issuecomment-2845767048
  - Maybe combine both approaches: Approach 1 for sdk 34, and Approach 2 for latest sdk?


# Resources
- https://ertt.ca/nix/shell-scripts/
- https://nixos.org/guides/nix-pills/20-basic-dependencies-and-hooks
- https://ryantm.github.io/nixpkgs/builders/trivial-builders/#chap-trivial-builders
