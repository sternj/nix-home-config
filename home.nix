{ config, pkgs, lib, ... }:

let localInfo = import ./local_info.nix; 
in {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = localInfo.userName;
  home.homeDirectory = localInfo.homeDirectory;

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
  home.packages = [
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
    pkgs.jq
    pkgs.fd
    pkgs.pyenv
    pkgs.numbat
    pkgs.hck
    pkgs.delta
    pkgs.bat
    pkgs.eza
    pkgs.zsh-powerlevel10k
    pkgs.git
    pkgs.fzf
    pkgs.zoxide
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
  home.file.".p10k.zsh".text = builtins.readFile ./dotfiles/.p10k.zsh;
}
