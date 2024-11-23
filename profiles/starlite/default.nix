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


  # networking.hostName = "starlite"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
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


  # Enable the X11 windowing system.
  # services.xserver.enable = true;
    # Enable automatic login for the user.
  # services.xserver.displayManager.autoLogin.enable = true;
  # services.xserver.displayManager.autoLogin.user = "gustav";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

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
  ])   ++ (with pkgs.gnome; [
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

  # Enable CUPS to print documents.
  # services.printing.enable = true;


  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nixd
    gnomeExtensions.appindicator # tray icon
    gnomeExtensions.screen-rotate # see https://www.reddit.com/r/starlabs_computers/comments/1dyebde/starlite_mkv_autorotate_solution/
    krita
    flashrom
  ];


  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}