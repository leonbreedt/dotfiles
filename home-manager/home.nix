{ config, pkgs, ... }:

{
  home.stateVersion = "22.11";

  home.username = "leon";
  home.homeDirectory = "/Users/leon";

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
      set -gx NIX_PATH $HOME/.nix-defexpr $HOME/.nix-defexpr/channels
    '';
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs; [
      vimPlugins.lightline-vim

      # LSP
      vimPlugins.nvim-lspconfig

      # languages
      vimPlugins.rust-vim
      vimPlugins.vim-nix

      # completion
      vimPlugins.cmp-nvim-lsp
      vimPlugins.cmp-buffer
      vimPlugins.cmp-path
      vimPlugins.cmp-cmdline
      vimPlugins.nvim-cmp
      vimPlugins.cmp-vsnip
      vimPlugins.vim-vsnip

      # popups
      vimPlugins.popfix

      # tree sitter
      (vimPlugins.nvim-treesitter.withPlugins (plugins: with plugins; [
        tree-sitter-c
        tree-sitter-cpp
        tree-sitter-go
        tree-sitter-nix
        tree-sitter-rust
      ]))
    ];
    
    extraConfig = builtins.readFile ./config/nvim;

    # Language servers
    extraPackages = with pkgs; [
      rust-analyzer
      gopls
    ];
  };

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "tty";

    # cache the keys forever so we don't get asked for a password
    defaultCacheTtl = 31536000;
    maxCacheTtl = 31536000;
  };
}
