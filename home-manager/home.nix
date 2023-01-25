{ config, pkgs, ... }:

{
  home.stateVersion = "22.11";

  home.username = "leon";
  home.homeDirectory = if pkgs.stdenv.isLinux then "/home/leon" else "/Users/leon";

  home.sessionVariables = {
    TERM = "xterm-256color";
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "bat -p";
    MANPAGER = "bat -p";
  };

  # managed config files
  home.file.".gnupg/gpg-agent.conf".source = if pkgs.stdenv.isLinux then ./config/gpg-agent-linux else ./config/gpg-agent-darwin;
  home.file.".gnupg/pubring.gpg".source = ../private/pubring.gpg;
  home.file.".gnupg/secring.gpg".source = ../private/secring.gpg;
  home.file.".gnupg/trustdb.gpg".source = ../private/trustdb.gpg;
  home.file.".ssh/id_rsa".source = ../private/id_rsa;
  home.file.".ssh/id_rsa.pub".source = ../private/id_rsa.pub;
  home.file.".git-credentials".source = ../private/git-credentials;

  # user-specific packages
  home.packages = with pkgs; [
    awscli2
    bat
    du-dust
    exa
    fd
    flyctl
    fzf
    htop
    jetbrains-mono
    jq
    pinentry
    pwgen
    ripgrep
    shellcheck
    terraform
    tree
    wrk
    xsv

    # work
    jdk
    maven
    nodejs-16_x
    git-lfs
    google-java-format
    chromedriver
  ];

  # programs

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
      cat = "bat -p";
    };
    shellInit = ''
      if test -e /nix/var/nix/profiles/default/etc/profile.d/nix.fish
        # Nix paths on macOS
        source /nix/var/nix/profiles/default/etc/profile.d/nix.fish
        set -gx PATH /nix/var/nix/profiles/default/bin $PATH
      end

      set -gx NIX_PATH $HOME/.nix-defexpr $HOME/.nix-defexpr/channels

      # JetBrains shell scripts
      if test -d "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
        # macOS
        set -gx PATH "$HOME/Library/Application Support/JetBrains/Toolbox/scripts" $PATH
      end

      # Git commit signing
      set -gx GPG_TTY (tty)

      # CDPATH for work
      set -tx CDPATH $HOME/SAPDevelop
    '';
    plugins = [
      {
        name = "theme-bobthefish";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "theme-bobthefish";
          rev = "2dcfcab653ae69ae95ab57217fe64c97ae05d8de";
          sha256 = "sha256-jBbm0wTNZ7jSoGFxRkTz96QHpc5ViAw9RGsRBkCQEIU=";
        };
      }
    ];
  };

  programs.kitty = {
    enable = true;
    extraConfig = builtins.readFile ./config/kitty;
  };

  programs.git = {
    enable = true;
    userName = "Leon Breedt";
    userEmail = "leon@sector42.io";
    signing = {
      key = "8EDF16F241C988805D6019FDC7FC3270F57FA785";
      signByDefault = true;
    };
    aliases = {
      co = "checkout";
      ca = "commit --all";
      fa = "fetch --all";
      fap = "!git fetch --all && git pull --autostash";
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      st = "status";
      root = "rev-parse --show-toplevel";
    };
    extraConfig = {
      branch.autosetuprebase = "always";
      color.ui = true;
      color.diff = "auto";
      color.status = "auto";
      color.interactive = "auto";
      color.pager = true;
      core.askPass = "";
      credential.helper = "store";
      github.user = "leonbreedt";
      push.default = "tracking";
      pull.rebase = true;
      init.defaultBranch = "main";
    };
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
      vimPlugins.vim-fish

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
  programs.direnv.enable = true;

  # Overlays
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
