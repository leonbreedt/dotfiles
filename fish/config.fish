# Nix: Install on macOS by following https://nixos.org/download.html#nix-install-macos
set nix_profile /nix/var/nix/profiles/default
set nix_config $nix_profile/etc/profile.d/nix.fish
if test -e $nix_config
  source $nix_config
end

# Nix: make other tools like nix-shell use same expression as nix-env.
set -gx NIX_PATH $HOME/.nix-defexpr

# Path
set -gx PATH $HOME/.cargo/bin $nix_profile/bin $PATH
