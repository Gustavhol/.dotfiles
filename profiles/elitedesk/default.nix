# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  inputs,
  pkgs,
  unstablePkgs,
  userSettings,
  systemSettings,
  nix-colors,
  nixvim,
  vscode-server,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./../common/common-nixos.nix
    ./../common/pipewire.nix
    ./../../services/plasma6/plasma6.nix
  ];  
  nixpkgs.config.permittedInsecurePackages = [
    "qtwebengine-5.15.19"
  ];

  boot = { 
    supportedFilesystems = ["zfs"];
    zfs.extraPools = [ "backups" ];
  };

  # fileSystems."/mnt/backups" = {
  #   device = "backups";
  #   fsType = "zfs";
  #   options = ["zfsutil" "noauto"];
  # };

  networking = {
    hostName = "elitedesk"; # Define your hostname.
    hostId = "336bf6d2";
    firewall = {
      enable = true;
         allowedTCPPorts = [
           45876
         ];
      #   allowedUDPPortRanges = [
      #     { from = 1714; to = 1764; } # KDE Connect
      #   ];
    };

    # wlp1s0 is a redundant second path that turned out not to be inert. eno1 already carries the
    # default route (metric 100 against wlp1s0's 600) and every route this host actually uses, so
    # nothing depends on the wireless. But both interfaces sit on 192.168.1.0/24, which lets
    # traffic arrive over either one — and that is why elitedesk had the jitteriest path to
    # golmsten of the three hosts measured on 2026-11-23 (3.036/8.447/18.551 ms, mdev 6.005,
    # against 3.281/3.677/4.291, mdev 0.404 from primpan, both same switch as this host).
    # Hand the device to nobody rather than letting NetworkManager keep a live connection on it.
    # Verified against the NixOS manual, which uses the same `interface-name:` device spec.
    networkmanager.unmanaged = [ "interface-name:wlp1s0" ];
  };

  services = {
    printing.enable = true;
    flatpak.enable = true;    
    zfs = {
      autoScrub = {
        enable = true;
        interval = "weekly";};
    };
  };


  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  environment.systemPackages = with pkgs; [
    alejandra
    # angryipscanner
    kitty
    nfs-utils
    nixd
    nixpkgs-fmt
    squeezelite
  ];

  system.stateVersion = "24.11"; # DO NOT CHANGE!!!
}
