{ config, pkgs, unstablePkgs, inputs, nixvim, ... }:

{  
  home.username = "gustav";
  home.homeDirectory = "/home/gustav";

  # programs.home-manager.enable = true;

  imports = [
    inputs.nix-colors.homeManagerModules.default
    inputs.nixvim.homeManagerModules.nixvim
    ./app/alacritty.nix
    ./app/git.nix
    ./app/kitty.nix
    ./app/nixvim.nix
    ./app/zsh.nix
  ];

  # colorScheme = nix-colors.colorSchemes.onedark;

  home.stateVersion = "23.11"; # Please read the comment before changing.

  home.packages = 
  ( with pkgs; [
    lunarvim
    unicode-emoji
    starship
    eza
    # orca-slicer
    flameshot
    transmission_4
    vscode
    vlc
    # firefox
    element-desktop
    gnomeExtensions.gsconnect
    gnomeExtensions.touch-x
  ])
  ++ 
  ( with unstablePkgs; [
    orca-slicer
    beeper
    google-chrome
    obsidian
    rpi-imager
    spotify
    vivaldi
  ]);

  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.sessionVariables = {
      EDITOR = "nvim";
      TERM = "xterm-kitty";
      NIXOS_OZONE_WL = "1";
  };

  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "touchx@neuromorph"
        "gsconnect@andyholmes.github.io"
    ];
    };
  };

  programs = {
    home-manager = {
      enable = true;
    };
    # zsh = {
    #   enable = true;
    #   shellAliases = {
    #     ls = "${pkgs.eza}/bin/eza --icons -l -T -L=1 --group-directories-first";
    #     la = "${pkgs.eza}/bin/eza --icons -l -a -h -T -L=1 --group-directories-first";
    #     tree = "${pkgs.eza}/bin/eza --color=auto --tree";
    #     grep = "grep --color=auto";
    #     ":q" = "exit";
    #     hmsf = "home-manager switch --flake .#user";
    #     nrsf = "sudo nixos-rebuild switch --flake .#desktop";
    #   };
    # };
    starship = {
      enable = true;
      enableZshIntegration = true;
    };
    bash = {
      enable = true;
    };
    mpv = {
      enable = true;
    };
    /* nixvim = {
      enable = true;
      colorschemes.onedark.enable = true;
    }; */
    firefox = {
      enable = true;
      profiles.gustav = {
        extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
          bitwarden
          ublock-origin
          sponsorblock
          decentraleyes
          privacy-badger
          clearurls
        ];
      };
    };
  };

}
