#!/usr/bin/env fish

set KITTY_CONF $HOME/.dotfiles/home-manager/config/kitty

set FONT_FAMILY $argv[1]
set FONT_SIZE $argv[2]

function info
  echo (set_color --bold)info(set_color normal): $argv
end

function success
  echo (set_color --bold green)ok(set_color normal): $argv
end

function fail
  echo (set_color --bold red)error(set_color normal): $argv
  exit 1
end

if test -z "$FONT_FAMILY"
  fail "at least font family must be provided as argument"
end

if ! test -w "$KITTY_CONF"
  fail "$KITTY_CONF does not exist or is not writable"
end

info "updating $KITTY_CONF"

set TMP_KITTY_CONF (mktemp -t kittyconf)

info "setting font family to $FONT_FAMILY"
sed -e "s|.*font_family.*|font_family $FONT_FAMILY|g" < $KITTY_CONF > $TMP_KITTY_CONF
  or fail "could not set font family"

if test -n "$FONT_SIZE"
  info "setting font size to $FONT_SIZE"
  sed -ie "s|.*font_size.*|font_size $FONT_SIZE|g" $TMP_KITTY_CONF
    or fail "could not set font size"
end

mv -f $TMP_KITTY_CONF $KITTY_CONF

info "switching to new configuration"
home-manager switch

info "killing all running Kitty instances"
pkill kitty

info "starting new Kitty instance"
nohup kitty &
