# About

Devix is a project created to easily setup and configure your develoepr environment.
This is done through configuring "devProfiles" and "devModules" in a nix flake file.


# Getting Started

## Quickstart

1.Create a new project nix template...

```
nix flake new -t github:rencire/devix/main <your_project>

```

or initialize exsting project with template in your project directory:

```
cd <your_project>
nix flake init github:rencire/devix/main
```

2. Go to <your_project> and allow direnv to autoload your shell

```
direnv allow
```

3. Modify `flake.nix` with modules and settings for your proejct
   (See below section for example)

4. Save file, return to shell, and watch your dependencies download automatically.

## Example flake

You can call this flake directly and enable modules as needed from your `flake.nix`.
Here's an example creating a developer environment with android module:

```nix
{
  inputs.devix.url = "github:rencire/devix";
  outputs = { devix, ... }: devix ./. {
    # Developer profiles available under `devProfiles`.
    inherit inputs;
    systems = [
      # Add systems for your machine here
      "aarch64-darwin"
    ];
    # This is main attribute set where we define our developer environment settings
    devProfiles = {
      android-dev-env = {
        enable = true;
        # See  module/android for available options
        platform.versions = [ "34" ];
        abis = [
          "arm64-v8a"
        ];
      };
    };
    # Can add other nix flake outputs attributes here
  };
}
```


Alternatively, if you're already using [`flakelight`](https://github.com/nix-community/flakelight), you can
add `devix` as a `flakelight` module.
This is useful if you also have other flakelight modules to import:

```nix
{
  inputs = {
    flakelight.url = "github:nix-community/flakelight";
    devix.url = "github:rencire/devix";
  };
  outputs = { flakelight, flakelight-rust, ... }: flakelight ./. {
    imports = [
      devix.flakelightModules.default
      # Add other flakelight modules here
    ];
    devProfiles = {
       # Devix profile settings here
    };
    # Rest of nix flake configuration goes here...
  };
}
```

Other than `devProfiles` and `devModules`, you can add other standard`flakelight`/`nix flake` attributes as well.

Here's an example with `devShell`:

```nix
{
  inputs.devix.url = "github:rencire/devix";
  outputs = { devix, ... }: devix ./. {
    # Developer profiles and modules available under `devProfiles` and `devModules`.
    inherit inputs;
    systems = [
      # Add systems for your machine here
      "aarch64-darwin"
    ];
    # This is main attribute set where we define our module settings
    devProfiles = {
    # Dev profile settings here. Most likely would use this over `devModules`
    };
    devModules = {
    # Dev module settings here. 
    };
    # Can add other nix flake outputs attributes here.  
    devShell = pkgs: {
      packages = with pkgs; [hello];
      env = {
        MY_ENV_VAR = "my env var";
      }
      shellHook = ''
        echo $MY_ENV_VAR
      '';
    }
  };
}
```
Note: These attributes tend to accept a function with `pkgs` available, since `devix` itself is a [`flakelight`](https://github.com/nix-community/flakelight)
module.
- See: https://github.com/nix-community/flakelight/blob/master/API_GUIDE.md



# Resources

- Dependencies:
  - [nix](https://nixos.org/)
  - [flakelight](https://github.com/nix-community/flakelight)
- Similar projects/inspiratino:
  - [devenv](https://github.com/cachix/devenv)




# TODO
- [] Remove high "devmods" namespace? Maybe use only "devmods" and "devprofiles" as top-level attributes:
  - Maybe rename project to "devo", or "flaked", or "devflake"?
