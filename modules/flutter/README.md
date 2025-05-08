# TODO
- [] Add instructions for quickstart, now that we have basic flutter project working w/ android sdk 34
- [] refactor "import ./<filename>.nix" to use the "imports = [ <filename> ]" pattern instead for idomatic nix.
- [x] Change `compileSdkVersion` option to `android.compileSdkVersion` for clarity.


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
      - Could not get this to work however for me; suspect there might be a mix of issues users
        are reporting on that GB issue

## Approaches try:
- [] Attempt to patch the flutter_tools/templates/app/build.gradle.kts, instead of replacing the
  - via shell script
  - Try this for flutter 3.27
- [x] Side exp: see if we can override template groovy files with kotlin.
  - Tried adding filess, but kotlin files not loading, even with `flutter create --android-language kotlin`
- [] Another approach: use flutter 3.29, but downgrade gradle to 8.8.  Then apply patch to android/build.gradke.kts
  - got tip from: https://github.com/NixOS/nixpkgs/issues/395096#issuecomment-2840719852
  - Not sure how to manage gradle version from nix (8.8), since it looks like flutter/android by default its using `gradlew` and manages
    its own gradle executable.
  - Downgraded version in gradle properties file, but couldn't use 8.8 sinee flutter complained android-flugger-gradle plugin ned 8.9.
    when upgraded to 8.9
  - Decided to skip all these approaches, and go wit hsimple approach below.


## Summary
- At the end, decided to just have a simple script to overwrite compileSdk, instead of dealing
  with flutter/gradle code (got tired from failed approaches above)
   

# Resources
- https://ertt.ca/nix/shell-scripts/
- https://nixos.org/guides/nix-pills/20-basic-dependencies-and-hooks
- https://ryantm.github.io/nixpkgs/builders/trivial-builders/#chap-trivial-builders
