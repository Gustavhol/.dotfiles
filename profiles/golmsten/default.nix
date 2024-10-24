# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, inputs, pkgs, unstablePkgs, userSettings, systemSettings, nix-colors, nixvim, vscode-server, ... }:

{
  imports = [
      ./hardware-configuration.nix
      ./../common/common-nixos.nix
      ./../common/pipewire.nix
      ./nvidia.nix
    ];

  boot.supportedFilesystems = ["zfs"];

  fileSystems."/data" = { 
    device = "data";
    fsType = "zfs";
    options = [ "zfsutil" "noauto" ];
  };

  networking = {
    hostName = "golmsten";
    hostId = "336bf6d7";
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
    zfs = {
      autoScrub.enable = true;

    };
    ollama = {
      enable = true;
      package = unstablePkgs.ollama;
      acceleration = "cuda";
    };
    flatpak = {
      enable = true;
    };
    syncthing = {
      enable = true;
      openDefaultPorts = true;
      configDir = "/home/gustav/.config/syncthing";
    };
  };

  environment.systemPackages = (with pkgs; [
     kdePackages.kdeconnect-kde
     angryipscanner
     nixd
  ]) ++ (with unstablePkgs; [
    #(pkgs.ollama.override { enableCuda = true; })
    ollama
    fabric-ai
  ]);

  programs.kdeconnect.enable = true;

  system.stateVersion = "24.05"; # DO NOT CHANGE!!! 
  }
