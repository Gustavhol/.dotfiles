{ config, pkgs, lib, ...}:

{
  networking = {
    firewall = { 
      enable = true;
      allowedTCPPorts = [ 3389 ];
      allowedTCPPortRanges = [ 
        { from = 1714; to = 1764; } # KDE Connect
      ];  
      allowedUDPPortRanges = [ 
        { from = 1714; to = 1764; } # KDE Connect
      ];  
    };   
  };

  services = {  
    xserver = {
      enable = true;
      xkb.layout = "se";
      xkb.variant = "";
    };
    displayManager = {
      sddm.enable = true;
      sddm.wayland.enable = true;
      autoLogin = {
        enable =true;
        user = "gustav";
      };
    };
    desktopManager = {
      plasma6.enable = true;
    };
  };

  xdg.portal = {
  enable = true;
  extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  };


  environment.systemPackages = with pkgs; [
    kdePackages.kdeconnect-kde
    kdePackages.kio-admin
    kdePackages.krdp
  ];

  programs.kdeconnect.enable = true;
}