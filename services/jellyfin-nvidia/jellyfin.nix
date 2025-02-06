{config, pkgs, lib, ...}:

{

  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
    ];


  services.jellyfin = {
    enable = true;
    dataDir = "/var/lib/jellyfin"; # Default location for metadata
    openFirewall = true;
  };

  hardware = {
    graphics.enable = true; # Required for hardware acceleration

  };

  users.extraGroups = {
    video.members = [ "jellyfin" ]; # Grant Jellyfin access to video hardware
  };

}
