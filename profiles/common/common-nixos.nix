# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, pkgs-unstable, userSettings, systemSettings, inputs, ... }:

{

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (_: true);
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 7;

  systemd.services.NetworkManager-wait-online.enable = false;
 
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 15d";
  };

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${userSettings.username} = {
    isNormalUser = true;
    description = userSettings.name;
    hashedPassword = "$y$j9T$GDQYpeHXABiM.DhOJbDDq.$WpAwWEHSj7xdoDyHn0.mIIz/PaOVWRFcEAl6bO2hQk6";
    extraGroups = [ "networkmanager" "wheel" "docker"];
    packages = 
    (with pkgs; [
      syncthing
      # inputs.nixvim.packages.${systemSettings.system}.default
    ])
    ++
    (with pkgs-unstable; [
      
    ]);
  };

  environment.systemPackages = with pkgs; [
     btop
     docker-compose
     ffmpeg
     flatpak
     fzf
     git
     gotop
     htop
     jq
     just
     mpv
     nil
     ripgrep
     pkgs.tailscale
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
 
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  environment.shells = with pkgs; [ zsh ];

  users.defaultUserShell = pkgs.zsh;

  services = {
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
