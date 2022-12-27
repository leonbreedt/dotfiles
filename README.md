# dotfiles

## Setup

### macOS

*Last tested on a clean macOS Ventura 13.1 installation.*

This assumes a clean macOS installation with nothing else on it yet.

- Open Terminal, run `git`, install Command Line Developer Tools if prompted.

- Clone this repository into `$HOME/.dotfiles`.

  ```shell
  git clone --recurse-submodules https://github.com/leonbreedt/dotfiles $HOME/.dotfiles
  ```

- Install Nix

  ```shell
  sh <(curl -L https://nixos.org/nix/install)
  ```

- Restart the Terminal so that the `nix-env` command is on the `PATH`, it got
  there by the Nix installer updating `/etc/zshrc` and `/etc/bashrc`.

- Install the [fish](https://fishshell.com) shell using Nix.

  ```shell
  nix-env -iA nixpkgs.fish
  ```

- Run the setup script, this will prompt you for your password as it runs
  `sudo` to add [home-manager](https://rycee.gitlab.io/home-manager/) to the
  system Nix channels.

  ```shell
  cd $HOME/.dotfiles
  ./install.fish
  ```

- This will take a while to set up *home-manager* and also install all of the
  required software.

### Windows (WSL)

- Download the latest NixOS release from <https://github.com/nix-community/NixOS-WSL>,
  and install it:

  ```shell
  cd $DISTRODIR
  wsl --import NixOS-22.05 .\NixOS\ nixos-wsl-installer.tar.gz --version 2
  ```

- Start it, either via Terminal drop-down, or:

  ```shell
  wsl -d NixOS-22.05
  ```

  On first start it will do a bunch of setup actions, then start systemd. If
  it hangs starting systemd, this may be <https://github.com/nix-community/NixOS-WSL/issues/156>.
  If so, run `wsl --shutdown` in a separate terminal and restart it.

- Edit `/etc/nixos/configuration.nix` with `nano`:

    ```plaintext
    wsl.defaultUser = "leon";
    wsl.docker-native.enable = true;

    environment.systemPackages = [ pkgs.fish pkgs.git ];

    users.users.leon = {
      isNormalUser = true;
      home = "/home/leon";
      description = "Leon Breedt";
      extraGroups = [ "wheel" "docker" ];
      shell = pkgs.fish;
    };
    ```

- Run `sudo nixos-rebuild switch` to ensure fish is installed and custom user created,
  restart the terminal.

- Make it the default WSL distribution (in a separate terminal window):

  ```shell
  wsl -s NixOS-22.05
  ```

- Clone this repository into `$HOME/.dotfiles`.

  ```shell
  git clone --recurse-submodules https://github.com/leonbreedt/dotfiles $HOME/.dotfiles
  ```

- Run the setup script:

  ```shell
  cd $HOME/.dotfiles
  ./install.fish
  ```

## Use

Install everything else via *home-manager* by editing `$HOME/.config/nixpkgs/home.nix`,
and then running the `home-manager switch` command.
