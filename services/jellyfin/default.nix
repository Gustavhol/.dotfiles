{config, pkgs, lib, ...}:

{

  environment.systemPackages = with pkgs; [
    nfs-utils
    intel-media-driver
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
    ];
  
  fileSystems."/mnt/media" = {
    device = "192.168.1.9:/data/media";
    fsType = "nfs";
    options = [ "rsize=8192" "wsize=8192" "timeo=14" "intr" ];
  };

  services.jellyfin = {
    enable = true;
    dataDir = "/var/lib/jellyfin"; # Default location for metadata
    openFirewall = true;
  #  bind = "0.0.0.0"; # Listen on all network interfaces
  #  extraOptions = "--ffmpeg=/path/to/ffmpeg"; # Optional: Specify custom ffmpeg if needed
  };

  hardware = {
    opengl.enable = true; # Required for hardware acceleration
    # video = {
    #   acceleration.vaapi = true; # Enable VA-API for Quick Sync
    #   drivers = [ "intel-media-driver" ];
    # };
  };

  users.extraGroups = {
    video.members = [ "jellyfin" ]; # Grant Jellyfin access to video hardware
  };

  networking = {
    firewall = {
      allowedTCPPorts = [ 2049 111 ]; # Default ports for Jellyfin and NFS
      allowedUDPPorts = [ 2049 111 ]; # Default ports for NFS
    };
  };
}
