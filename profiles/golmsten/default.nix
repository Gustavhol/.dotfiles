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
    ./nvidia.nix
    ./../common/common-nixos.nix
    ./../common/pipewire.nix
    ./../../services/vikunja/vikunja.nix
    ./../../services/plasma6/plasma6.nix
    ./../../services/jellyfin-nvidia/jellyfin.nix
  ];

  boot.supportedFilesystems = ["zfs"];

  fileSystems."/data" = {
    device = "data";
    fsType = "zfs";
    options = ["zfsutil" "noauto"];
  };

  networking = {
    hostName = "golmsten";
    hostId = "336bf6d7";
    firewall = {
      enable = true;
      allowedTCPPorts = [
        2049
        111
      ];
      allowedUDPPorts = [
        2049
        111
      ];
    };
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  services = {
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
      dataDir = "/home/gustav";
      openDefaultPorts = true;
      configDir = "/home/gustav/.config/syncthing";
      user = "gustav";
      group = "users";
      guiAddress = "0.0.0.0:8384";
    };
    nfs.server = {
      enable = true;
      exports = ''
        /data/media 192.168.1.0/24(rw,sync,no_subtree_check)
      '';
    };
  };

  environment.systemPackages =
    (with pkgs; [
      alejandra
      angryipscanner
      grsync
      nfs-utils
      nixpkgs-fmt
      stremio
    ])
    ++ (with unstablePkgs; [
      ollama
      fabric-ai
    ]);

  system.stateVersion = "24.05"; # DO NOT CHANGE!!!
}
