# dotfiles

## setup

First, install Nix, as we will be getting all our packages from there, even our
shells.

```shell
sh <(curl -L https://nixos.org/nix/install)
```

Run `nix-env -iA nixpkgs.fish`, and make sure `fish` is in the `PATH`.

Then, run `./install.fish` to finish setting up, and install [home-manager](https://nix-community.github.io/home-manager/index.html).

## use

Install everything else via home-manager by editing `$HOME/.config/nixpkgs/home.nix`,
and the `home-manager switch` command.

