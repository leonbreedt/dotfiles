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
      # Theme/appearance
      vimPlugins.lightline-vim
      localVimPlugins.catppuccin-nvim

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
      localVimPlugins.popui-nvim

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

  nixpkgs.overlays = [
    (self: super:
      {
        localVimPlugins = with self; {
          catppuccin-nvim = vimUtils.buildVimPlugin {
            name = "catppuccin-nvim";
            src = fetchFromGitHub {
              owner = "catppuccin";
              repo = "nvim";
              rev = "cd676faa020b34e6617398835b5fa3d1c2e8895c";
              sha256 = "00lww24cdnayclxx4kkv19vjysdw1qvngrf23w53v6x4f08s24my";
            };
          };

          popui-nvim = vimUtils.buildVimPlugin {
            name = "popui-nvim";
            src = fetchFromGitHub {
              owner = "hood";
              repo = "popui.nvim";
              rev = "5836baf9514f1a463e6617b5ea72669b597f8259";
              sha256 = "1ga4n5b7p4v96nnfjbmy0b6zzacwnp2axyqmckgd52wn3lg407q9";
            };
          };
        };
      }
    )
  ];
}
