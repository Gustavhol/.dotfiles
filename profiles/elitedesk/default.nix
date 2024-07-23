# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, inputs, pkgs, unstablePkgs, userSettings, systemSettings, nix-colors, nixvim, vscode-server, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./../common/common-nixos.nix
      ./../common/pipewire.nix
    #  nixvim.nixosModules.nixvim
    ];

  networking = {
    hostName = "elitedesk"; # Define your hostname.
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

  services = {
  # Enable the X11 windowing system.    
    xserver = {
      enable = true;
      xkb.layout = "se";
      xkb.variant = "";
    };
    displayManager = {
      sddm.enable = true;
      sddm.wayland.enable = true;
      autoLogin.enable = true;
      autoLogin.user = "gustav";
    };
    desktopManager = {
      plasma6.enable = true;
    };
    printing.enable = true;
  };

  environment.systemPackages = with pkgs; [
     kdePackages.kdeconnect-kde
  ];

  programs.kdeconnect.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  system.stateVersion = "23.11"; # DO NOT CHANGE!!! 
  }
