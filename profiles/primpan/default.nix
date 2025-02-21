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
    ./hardware-configuration.nix
    ./../common/common-nixos.nix
    ./../common/pipewire.nix
    ./../../services/plasma6/plasma6.nix
  ];

  boot.supportedFilesystems = ["zfs"];

  # fileSystems."/data" = {
  #   device = "data";
  #   fsType = "zfs";
  #   options = [ "zfsutil" "noauto" ];
  # };

  networking = {
    hostName = "primpan";
    hostId = "336bf6d8";
    firewall = {
      enable = true;
      # allowedTCPPortRanges = [
      #   { from = 1714; to = 1764; } # KDE Connect
      # ];
      # allowedUDPPortRanges = [
      #   { from = 1714; to = 1764; } # KDE Connect
      # ];
    };
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  services = {
    zfs = {
      autoScrub = {
        enable = true;
        interval = "weekly";};
    };
    syncthing = {
      enable = true;
      dataDir = "/home/gustav";
      openDefaultPorts = true;
      configDir = "/home/gustav/.config/syncthing";
      user = "gustav";
      group = "users";
      guiAddress = "0.0.0.0:8384";
    };
  };

  environment.systemPackages =
    (with pkgs; [
      angryipscanner
      grsync
      nfs-utils
    ])
    ++ (with unstablePkgs; [
      ]);

  # programs.kdeconnect.enable = true;

  system.stateVersion = "24.05"; # DO NOT CHANGE!!!
}
