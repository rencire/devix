# TODO
- [] Get rid of the default versions.
  - We should not pass in options if user has not specified them. Then, androidenv will handle getting the latest version.
- [] Track gradle version in nix.
- [] Allow setting Android Gradle Plugin (AGP) version.
  - Need to downgrade (see: https://github.com/NixOS/nixpkgs/issues/395096#issuecomment-2850983875)


# Support Matrix
| host os | host architecture | target platform | target platform version | target architecture |  Status        | Notes 
|---------|-------------------|-----------------|-------------------------|---------------------|----------------------------------------------------------------------------|
| darwin  | arm64-darwin      | android         | 34                      | arm64-v8a           | Able to launch | able to run the "flutter create" app on emulator.         |
| darwin  | arm64-darwin      | macos           | 15.4                    | arm64-darwin        | Able to launch | able to run the "flutter create" app on a desktop window. |


### Notes:
- Could not get Android 35 to work, some issue with AGP version, and maybe Gradle as well?
  - To be able to load app on android emulator, need to explicitly change `compleSdk` and `targetSdk` to `34` in <flutter_app>/android/app/build.gradle`.



