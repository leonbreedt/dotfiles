#!/usr/bin/env fish
# installs dotfiles to target directory (default is $HOME).

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
  link_file $DF_ROOT/fish/config.fish $HOME/.config/fish/config.fish prev
    or fail fish
  link_file $DF_ROOT/kitty/kitty.conf $HOME/.config/kitty.conf prev
    or fail kitty

  link_file $DF_ROOT/nix-defexpr/default.nix $HOME/.nix-defexpr/default.nix prev
    or fail nix
  link_file $DF_ROOT/nix-defexpr/home-manager/default.nix $HOME/.nix-defexpr/home-manager/default.nix prev
    or fail nix
  link_file $DF_ROOT/nix-defexpr/nixpkgs/default.nix $HOME/.nix-defexpr/nixpkgs/default.nix prev
    or fail nix
end

if ! grep -q (command -v fish) /etc/shells
  command -v fish | sudo tee -a /etc/shells
    and success 'added fish to /etc/shells'
    or fail 'setup /etc/shells'
  echo
else
  skip 'fish already registered in /etc/shells'
end

install_dotfiles

success 'dotfiles installed'
