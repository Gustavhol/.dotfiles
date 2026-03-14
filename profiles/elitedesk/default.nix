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
