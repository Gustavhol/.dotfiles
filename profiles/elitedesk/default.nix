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

  boot.supportedFilesystems = ["zfs"];

  fileSystems."/mnt/backups" = {
    device = "backups";
    fsType = "zfs";
    options = ["zfsutil" "noauto"];
  };

  networking = {
    hostName = "elitedesk"; # Define your hostname.
    hostId = "336bf6d2";
    firewall = {
      enable = true;
      #   allowedTCPPortRanges = [
      #     { from = 1714; to = 1764; } # KDE Connect
      #   ];
      #   allowedUDPPortRanges = [
      #     { from = 1714; to = 1764; } # KDE Connect
      #   ];
    };
  };

  services = {
    printing.enable = true;
    flatpak.enable = true;
  };

  environment.systemPackages = with pkgs; [
    alejandra
    angryipscanner
    kitty
    nfs-utils
    nixd
    nixpkgs-fmt
    squeezelite
  ];

  system.stateVersion = "24.11"; # DO NOT CHANGE!!!
}
