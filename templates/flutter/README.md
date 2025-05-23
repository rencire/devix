# Note
- This only has been tested with android target for flutter.  Currently it only supports android api level 34, gradle 8.8, and android gradle plugin 8.6.0. (see  [`preset settings`](https://github.com/rencire/devix/blob/33d024fb8ac97595ea88dd155b968cb19dcc2918/profiles/android-dev-env/default.nix#L37))
- This will automatically sync gradle, java, and androidGradlePlugins versions specified in nix connfiguration by **overwriting** the relevant android files in a typical flutter project (default android directory at `./android`).


# Quickstart

1.Create a new project directory via nix template...

```
nix flake new -t github:rencire/devix/main#flutter <your_project>

```

or initialize exsting project with template in your project directory:

```
cd <your_project>
nix flake init -t github:rencire/devix/main#flutter
```

2. Go into the project directory

3. Edit the flake.nix with your config:

```nix
{
  description = "Test flutter development environment";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.devix.url = "github:rencire/devix";
  outputs =
    { devix, ... }@inputs:
    devix ./. {
      inherit inputs;
      systems = [
        # Add your machine configuration here if not specified below already
        "aarch64-darwin"
        "x86_64-linux"
      ];
      devProfiles = {
        flutter-dev-env = {
          enable = true;
          android = {
            enable = true;
            # Only this preset is supported as of now
            presets = [ "android-api-34" ];
            # Add your android configuration here
            # For options, see modules/android/options.nix
            overrideModules = {
              android = {
                systemImageTypes = [
                  "google_apis"
                  "google_apis_playstore"
                ];
                abis = [
                  "armeabi-v7a"
                  "arm64-v8a"
                ];
              };
            };
          };
        };
      };
    };
}
 
```


4. Allow direnv so dependencies auto-reload:
```
direnv allow  
```

5. Go into the developer shell with:
```
nix develop
```

6. Run `flutter build apk`. The app should successfully build.




# Example Configurations

## Override android module in flutter dev env
We can add options to individual modules as well. For example, below we override
the android preset with our own setttings:

```nix
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
        "x86_64-linux"
      ];
      devProfiles = {
        flutter-dev-env = {
          enable = true;
          android = {
            enable = true;
            # Only this preset is supported as of now
            presets = [ "android-api-34" ];
            # In addition to presets, can optionally can override the android, gradle, and java modules
            # See options in modules/android/options.nix
            overrideModules = {
              android = {
                systemImageTypes = [
                  "google_apis"
                  "google_apis_playstore"
                ];
                abis = [
                  "armeabi-v7a"
                  "arm64-v8a"
                ];
              };
            };
          };
        };
      };
      # Add rest of nix flake configuration below (specifically flakelight)
      devShell = pkgs: {
        env = { };
        shellHook = "";
      };
    };
}

```
