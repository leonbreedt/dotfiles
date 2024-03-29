{ config, pkgs, ... }:

let userName = if builtins.pathExists "/Applications/Self Service.app" then "i070279" else "leon"; in
{
  nixpkgs.config.allowUnfree = true;

  manual.manpages.enable = false;
  manual.html.enable = false;
  manual.json.enable = false;

  home.stateVersion = "22.11";

  home.username = userName;
  home.homeDirectory = if pkgs.stdenv.isLinux then "/home/leon" else "/Users/${userName}";

  home.sessionVariables = {
    TERM = "xterm-256color";
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "bat -p";
    MANPAGER = "bat -p";

    # allow rust-analyzer to find the Rust source
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
  };

  # managed config files
  home.file.".gnupg/gpg-agent.conf".source = if pkgs.stdenv.isLinux then ./config/gpg-agent-linux else ./config/gpg-agent-darwin-${userName};
  home.file.".gnupg/pubring.gpg".source = ../private/pubring.gpg;
  home.file.".gnupg/secring.gpg".source = ../private/secring.gpg;
  home.file.".gnupg/trustdb.gpg".source = ../private/trustdb.gpg;
  home.file.".ssh/id_rsa".source = ../private/id_rsa;
  home.file.".ssh/id_rsa.pub".source = ../private/id_rsa.pub;
  home.file.".ssh/config".source = ../private/ssh-config;
  home.file.".ssh/ps_jaas_slave_01_rsa".source = ../private/ps-jenkins-worker-01.key;
  home.file.".ssh/ps_jaas_slave_02_rsa".source = ../private/ps-jenkins-worker-02.key;
  home.file.".git-credentials".source = ../private/git-credentials;
  home.file.".config/git/work".source = ../private/git-work;
  home.file.".config/git/personal".source = ../private/git-personal;

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
    jq
    neofetch
    pinentry
    pwgen
    ripgrep
    shellcheck
    terraform
    tree
    wrk
    xsv

    # frontend
    nodePackages.pnpm
    # needed for using tailwind LSP with fleet
    nodePackages."@tailwindcss/language-server"

    # rust
    rustc
    rustfmt
    cargo
    clippy

    # fonts
    jetbrains-mono
    cascadia-code

    # work
    kubectl
    kubelogin-oidc
    vault
    jdk17
    maven
    nodejs-16_x
    git-lfs
    google-java-format
    chromedriver
    cloudfoundry-cli
    vscode
  ];

  # programs

  programs.home-manager.enable = true;

  programs.go.enable = true;

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
      du = "dust -r";
      kc = "kubectl";
      less = "bat -p";
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

      # PostgreSQL (via Postgres.app) on macOS
      if test -d /Applications/Postgres.app/Contents/Versions/latest/bin
        set -gx PATH /Applications/Postgres.app/Contents/Versions/latest/bin $PATH
      end

      # Git commit signing
      set -gx GPG_TTY (tty)

      # CDPATH for work
      set -gx CDPATH $HOME/SAPDevelop

      # brew if installed
      if test -x /opt/homebrew/bin/brew
        eval (/opt/homebrew/bin/brew shellenv)
      end
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
    lfs.enable = true;
    aliases = {
      co = "checkout";
      ca = "commit --all";
      fa = "fetch --all";
      fap = "!git fetch --all && git pull --autostash";
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      st = "status";
      root = "rev-parse --show-toplevel";
    };
    includes = [
      {
        path = "~/.config/git/personal";
        condition = "gitdir:~/";
      }
      {
        path = "~/.config/git/personal";
        condition = "gitdir:~/Source/";
      }
      {
        path = "~/.config/git/work";
        condition = "gitdir:~/SAPDevelop/";
      }
    ];
    extraConfig = {
      branch.autosetuprebase = "always";
      color.ui = true;
      color.diff = "auto";
      color.status = "auto";
      color.interactive = "auto";
      color.pager = true;
      core.askPass = "";
      credential.helper = "store";
      credentialstore.locktimeoutms = 0;
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
