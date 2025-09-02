{
  config,
  pkgs,
  unstablePkgs,
  systemSettings,
  userSettings,
  inputs,
  system,
  ...
}: {
  # Enable the Home-Manager service itself
  programs.home-manager.enable = true;

  # Your user & directory
  home.username = userSettings.username;
  home.homeDirectory = "/home/${userSettings.username}";
  home.stateVersion = "23.11"; # adjust when you bump major versions

  # Import extra Home-Manager modules
  imports = [
    inputs.nix-colors.homeManagerModules.default
    inputs.nixvim.homeManagerModules.nixvim
    ./app/alacritty.nix
    ./app/git.nix
    ./app/kitty.nix
    ./app/nixvim.nix
    ./app/vscode.nix
    ./app/zsh.nix
    # inputs.firefox-addons.homeManagerModules.default
    # inputs.nix-minecraft.homeManagerModules.default
  ];

  # Packages: stable pkgs + a few unstable apps
  home.packages =
    (with pkgs; [
      lunarvim
      unicode-emoji
      starship
      eza
      flameshot
      transmission_4
      # vscode
      vlc
    ])
    ++ (with unstablePkgs; [
      orca-slicer
      beeper
      google-chrome
      obsidian
      rpi-imager
      spotify
      vivaldi
    ]);

  # Dotfiles, session vars, etc.
  # home.file = {
  #   ".screenrc".source = ./dotfiles/screenrc;
  # };

  home.sessionVariables = {
    EDITOR = userSettings.editor;
    TERM = userSettings.term;
  };

  # Shells, prompts, media player
  programs.zsh.enable = true;
  programs.starship.enable = true;
  programs.starship.enableZshIntegration = true;
  programs.bash.enable = true;
  programs.mpv.enable = true;

  # Firefox + extensions
  programs.firefox = {
    enable = true;
    profiles = {
      "${userSettings.username}" = {
        extensions.packages = with inputs.firefox-addons.packages.${system}; [
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

  # GNOME Shell extensions via dconf
  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "touchx@neuromorph"
        "gsconnect@andyholmes.github.io"
      ];
    };
  };
}
