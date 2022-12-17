{ config, pkgs, ... }:

{
  home.username = "leon";
  home.homeDirectory = "/Users/leon";

  home.stateVersion = "22.11";

  # user-specific packages
  home.packages = with pkgs; [
    bat
    du-dust
    exa
    fd
    fzf
    htop
    jdk
    jq
    pwgen
    ripgrep
    shellcheck
    tree
    wrk
    xsv
  ];

  programs.home-manager.enable = true;

  programs.fish = {
    enable = true;
    shellAliases = {
      ga = "git add";
      gc = "git commit";
      gca = "git commit --all";
      gco = "git co";
      gfa = "git fap";
      gd = "git diff";
      gl = "git lg";
      gp = "git push";
      gs = "git status";
      gt = "git tag";
    };
    shellInit = ''
      source /nix/var/nix/profiles/default/etc/profile.d/nix.fish
      set -gx PATH /nix/var/nix/profiles/default/bin $PATH
      set -gx NIX_PATH $HOME/.nix-defexpr
    '';
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs; [
      vimPlugins.lightline-vim
    ];
  };
}
