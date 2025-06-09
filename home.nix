{ config, pkgs, lib, ... }:
let 
  userName = builtins.trace "Home Manager configuration for user: ${builtins.getEnv "USER"} in directory: ${homeDirectory} (isContainer: ${toString isContainer})" (builtins.getEnv "USER");
  homeDirectory = builtins.getEnv "HOME";
  isContainer_env = (builtins.getEnv "IS_CONTAINER");
  isContainer = if (isContainer_env == "true" || isContainer_env == "1") then true else false;
  # nothing =  "";
in {


  # This is the Home Manager configuration for your user. It is used to manage
  home.username = userName;
  home.homeDirectory = homeDirectory;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    jq
    fd
    pyenv
    numbat
    hck
    delta
    bat
    eza
    zsh-powerlevel10k
    git
    fzf
    zoxide
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
    ".p10k.zsh".source = ./dotfiles/.p10k.zsh;
    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/sam/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.zsh = {
    enable = true;
    # If you want to use a custom Zsh configuration, you can set it here.

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;

      # You can also enable plugins and themes for Zsh.
      plugins = [
        "zoxide"
        "git"
        "dotenv"
        "fzf"
        
        # {name = "powerlevel10k";src = pkgs.zsh-powerlevel10k;file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";}

      ];
      # theme = "powerlevel10k/powerlevel10k";
    };
    shellAliases = {
      # You can define your own aliases here.
      # For example, to create an alias 'll' for 'ls -l':
      ll = "ls -l";
      cat = "bat -pp";
      ls = "exa";
    };
    
    sessionVariables = {
      # You can set session variables for Zsh here.
      # For example, to set the EDITOR variable:
      ZSH_DOTENV_PROMPT = "false";
      DISABLE_FZF_KEY_BINDINGS = "true";
      ZSH_DOTENV_FILE = ".env";
    };
    initContent = lib.mkOrder 500 ''
    USER="${config.home.username}"
    [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ] && . "$HOME/.nix-profile/etc/profile.d/nix.sh"

    if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
      source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
    fi
    source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
    [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

    '';
  };
  programs.pyenv = {
    enable = true;
    enableZshIntegration = true;
    # You can specify the Python versions you want to install and use.

  };
  programs.git = {
    enable = true;
    userName = "Sam Stern";
    userEmail = "jstern@umass.edu";
  };
  programs.tmux = lib.mkIf isContainer {
    enable = true;
    # You can specify your tmux configuration file here.
    # configFile = ./dotfiles/tmux.conf;
    plugins = with pkgs.tmuxPlugins; [
      # You can add your tmux plugins here.
      # For example, to add the 'tmux-resurrect' plugin:
      # tmux-resurrect
      {
        plugin = tmuxPlugins.catppuccin;
        extraConfig = '' 
        set -g @catppuccin_flavour 'mocha'
        set -g @catppuccin_window_tabs_enabled on
        set -g @catppuccin_date_time "%H:%M"
        '';
      }
      better-mouse-mode

    ];
    baseIndex = 1;
    keyMode = "vi";
    mouse = true;
    extraConfig = ''
    set-window-option -g pane-base-index 1
    set-option -g renumber-windows on
    bind '"' split-window -v -c "#{pane_current_path}"
    bind % split-window -h -c "#{pane_current_path}"
    '';
  };

  home.file.".p10k.zsh".text = builtins.readFile ./dotfiles/.p10k.zsh;
}
