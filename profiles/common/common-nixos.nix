# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  pkgs-unstable,
  userSettings,
  systemSettings,
  inputs,
  ...
}: {
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 7;

  systemd.services.NetworkManager-wait-online.enable = false;

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 15d";
  };

  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

  networking.networkmanager.enable = true;
  #  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  time.timeZone = systemSettings.timezone;

  i18n = {
    defaultLocale = systemSettings.locale;
    extraLocaleSettings = {
      LC_ADDRESS = systemSettings.locale;
      LC_IDENTIFICATION = systemSettings.locale;
      LC_MEASUREMENT = systemSettings.locale;
      LC_MONETARY = systemSettings.locale;
      LC_NAME = systemSettings.locale;
      LC_NUMERIC = systemSettings.locale;
      LC_PAPER = systemSettings.locale;
      LC_TELEPHONE = systemSettings.locale;
      LC_TIME = systemSettings.locale;
    };
  };

  console.keyMap = systemSettings.keymap;

  users.users.${userSettings.username} = {
    isNormalUser = true;
    description = userSettings.name;
    hashedPassword = "$y$j9T$GDQYpeHXABiM.DhOJbDDq.$WpAwWEHSj7xdoDyHn0.mIIz/PaOVWRFcEAl6bO2hQk6";
    extraGroups = ["networkmanager" "wheel" "docker" "dialout" "tty"];
    packages =
      (with pkgs; [
        syncthing
        # inputs.nixvim.packages.${systemSettings.system}.default
      ])
      ++ (with pkgs-unstable; [
        ]);
  };

  environment.systemPackages = with pkgs; [
    btop
    comma
    dig
    docker
    docker-compose
    ffmpeg
    flatpak
    fzf
    git
    glances
    go
    gotop
    htop
    jq
    just
    kio-admin
    kitty
    mpv
    nil
    nixd
    ripgrep
    rsync
    pkgs.tailscale
    tmux
    vim
    wget
    zellij
    zsh
    zsh-vi-mode
  ];

  fonts.packages = with pkgs; [
    fira-code
    nerdfonts
    noto-fonts
  ];

  programs = {
    zsh = {
      enableCompletion = true;
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
    };
    appimage = {
      enable = true;
      binfmt = true;
    };
  };

  environment.shells = with pkgs; [zsh];

  users.defaultUserShell = pkgs.zsh;

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  services = {
    glances = {
      enable = true;
      extraArgs = [
        "--webserver"
      ];
      openFirewall = true; # Port 61208
    };
    openssh.enable = true;
    tailscale.enable = true;
    xserver = {
      xkb = {
        layout = "se";
        variant = "";
      };
    };
  };
}
