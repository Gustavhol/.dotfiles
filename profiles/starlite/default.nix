# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, pkgs-unstable, userSettings, systemSettings, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./screen-rotation.nix
      ./hardware-configuration.nix
      ../common/common-nixos.nix
      ../common/pipewire.nix
    ];

    networking = {
    hostName = "starlite"; # Define your hostname.
    firewall = { 
      enable = true;
      allowedTCPPortRanges = [ 
        { from = 1714; to = 1764; } # KDE Connect
      ];  
      allowedUDPPortRanges = [ 
        { from = 1714; to = 1764; } # KDE Connect
      ];  
    };   
  };

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  services = {
      libinput.enable = true;
      displayManager = {
        autoLogin = {
          enable = true;
          user = "gustav";
        };
      };
      xserver = {
        enable = true;
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
      };
    printing.enable = true;
    flatpak.enable = true;
  };
       
  # Remove some GNOME default packages
  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
    cheese # webcam tool
    gnome-music
    gnome-terminal
    # gedit # text editor
    epiphany # web browser
    geary # email reader
    evince # document viewer
    gnome-characters
    totem # video player
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
    seahorse
  ]);

  environment.systemPackages = with pkgs; [
    nixd
    gnomeExtensions.appindicator # tray icon
    gnomeExtensions.screen-rotate # see https://www.reddit.com/r/starlabs_computers/comments/1dyebde/starlite_mkv_autorotate_solution/
    krita
    flashrom
  ];

  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  system.stateVersion = "23.11"; # Do not change!!!
}