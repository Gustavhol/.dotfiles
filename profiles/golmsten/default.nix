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
    ./../../services/nginx/nginx.nix
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
      #11000 nextcloud aio
      #2283 immich
      allowedTCPPorts = [
        2049
        111
        11000
        2283
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

  # nixpkgs.overlays = [
  #   (final: prev: {
  #     arduino-ide-env = prev.fhsUserEnv {
  #       name = "arduino-ide-env";
  #       targetPkgs = pkgs:
  #         with pkgs; [
  #           arduino-ide
  #           python3
  #           python312Packages.pyserial
  #         ];
  #       runScript = "${pkgs.arduino-ide}/bin/arduino-ide";
  #     };
  #   })
  # ];

  environment.systemPackages =
    (with pkgs; [
      alejandra
      angryipscanner
      grsync
      nfs-utils
      nixpkgs-fmt
      steam-run
      stremio
    #  arduino-ide
      esptool
      esptool-ck
      python3
    #  python311Packages.pyserial
    ])
    ++ (with unstablePkgs; [
      ollama
      fabric-ai
    ]);

  system.stateVersion = "24.05"; # DO NOT CHANGE!!!
}
