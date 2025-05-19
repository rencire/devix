# About

Devmods is a project created to easily setup and configure your develoepr environment.
This is done through configuring modules in a nix flake file.

# Getting Started

## Quickstart

1.Create a new project nix template...

```
nix flake new -t github:rencire/devmods/main <your_project>

```

or initialize exsting project with template in your project directory:

```
cd <your_project>
nix flake init github:rencire/devmods/main
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
  inputs.devmods.url = "github:rencire/devmods";
  outputs = { devmods, ... }: devmods ./. {
    # Developer Modules available under `devmods`.
    inherit inputs;
    systems = [
      # Add systems for your machine here
      "aarch64-darwin"
    ];
    # This is main attribute set where we define our module settings
    devmods = {
      android = {
        enable = true;
        # See android module for available options
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
add `devmods` as a `flakelight` module.
This is useful if you also have other flakelight modules to import:

```nix
{
  inputs = {
    flakelight.url = "github:nix-community/flakelight";
    devmods.url = "github:rencire/devmods";
  };
  outputs = { flakelight, flakelight-rust, ... }: flakelight ./. {
    imports = [
      devmods.flakelightModules.default
      # Add other flakelight modules here
    ];
    devmods = {
       # Devmod settings here
    };
    # Rest of nix flake configuration goes here...
  };
}
```

Other than `devmods`, you can add other standard`flakelight`/`nix flake` attributes as well.

Here's an example with `devShell`:

```nix
{
  inputs.devmods.url = "github:rencire/devmods";
  outputs = { devmods, ... }: devmods ./. {
    # Developer Modules available under `devmods`.
    inherit inputs;
    systems = [
      # Add systems for your machine here
      "aarch64-darwin"
    ];
    # This is main attribute set where we define our module settings
    devmods = {
    # Devmod settings here
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
Note: These attributes tend to accept a function with `pkgs` available, since `devmods` itself is a [`flakelight`](https://github.com/nix-community/flakelight)
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
