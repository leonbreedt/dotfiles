#!/usr/bin/env fish
# sets up dotfiles and home-manager.

set DF_TARGET $HOME
set DF_ROOT (pwd -P)

function info
  echo (set_color --bold)info(set_color normal): $argv
end

function success
  echo (set_color --bold green)ok(set_color normal): $argv
end

function skip
  echo (set_color --bold yellow)skip(set_color normal): $argv
end

function fail
  echo (set_color --bold red)error(set_color normal): $argv
  exit 1
end

function link_file -d "links a file keeping a backup"
  echo $argv | read -l old new backup
  if test -e $new
    set newf (readlink $new)
    if test "$newf" = "$old"
      skip $old
      return
    else
      mv $new $new.$backup
        and success moved $new to $new.$backup
        or fail "failed to backup $new to $new.$backup"
    end
  end
  mkdir -p (dirname $new)
    and ln -sf $old $new
    and success "linked $old to $new"
    or fail "could not link $old to $new"
end

function install_dotfiles -d "installs dotfiles by linking them to $DF_TARGET"
  # install the bare minimum dotfiles to make home-manager work,
  # manage the rest with home-manager
  link_file $DF_ROOT/nix-defexpr/default.nix $HOME/.nix-defexpr/default.nix prev
    or fail nix
  link_file $DF_ROOT/nix-defexpr/nixpkgs/default.nix $HOME/.nix-defexpr/nixpkgs/default.nix prev
    or fail nix
end

function bootstrap_homemanager -d "installs home-manager and activates configuration"
  # ensure we can execute Nix tools
  set nix_profile /nix/var/nix/profiles/default
  set nix_config $nix_profile/etc/profile.d/nix.fish
  if test -e $nix_config
    source $nix_config
  end
  set -gx PATH $nix_profile/bin $PATH

  # make sure nix-shell uses same expression as nix-env
  set -gx NIX_PATH $HOME/.nix-defexpr

  if ! command -q home-manager
    info 'installing home-manager'
    nix-channel --update
    nix-shell '<home-manager>' -A install
  else
    skip 'home-manager already installed'
  end
  link_file $DF_ROOT/home-manager/home.nix $HOME/.config/nixpkgs/home.nix prev
    or fail home-manager

  home-manager switch
end

function register_shell -d "registers a shell in /etc/shells"
  if ! grep -q $argv /etc/shells
    echo $argv | sudo tee -a /etc/shells
      and success "added $argv to /etc/shells"
      or fail "could not add $argv to /etc/shells"
  else
    skip "$argv already registered in /etc/shells"
  end
end

register_shell (command -v fish)

install_dotfiles
bootstrap_homemanager

success 'installation finished'
