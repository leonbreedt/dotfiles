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

## Use

Install everything else via *home-manager* by editing `$HOME/.config/nixpkgs/home.nix`,
and then running the `home-manager switch` command.
