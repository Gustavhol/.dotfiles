{ config, pkgs, lib, ...}:

{
  networking = {
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
#    printing.enable = true;
#    flatpak.enable = true;
  };

#  services = {
#    xserver = {
#      enable = true;
#    };
#    displayManager = {
#      gdm = {
#        enable = true;
#      };
#    };
#    desktopManager = {
#      gnome = {
#        enable = true;
#      };
#    };
#  };

  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  environment.gnome.excludePackages = (with pkgs; [
    atomix # puzzle game
    cheese # webcam tool
    epiphany # web browser
    evince # document viewer
    geary # email reader
    gnome-characters
    gnome-music
    gnome-photos
    gnome-terminal
    gnome-tour
    hitori # sudoku game
    iagno # go game
    seahorse
    tali # poker game
    totem # video player
  ]);
}
