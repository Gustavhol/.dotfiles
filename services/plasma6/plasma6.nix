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

  environment.systemPackages = with pkgs; [
    kdePackages.kdeconnect-kde
  ];

  programs.kdeconnect.enable = true;
}