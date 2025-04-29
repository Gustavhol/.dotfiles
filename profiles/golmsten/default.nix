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
  lib,
  ...
}: {
  imports = [
    ./backups.nix
    ./hardware-configuration.nix
    ./nvidia.nix
    ./../common/common-nixos.nix
    ./../common/pipewire.nix
    ./../../services/vikunja/vikunja.nix
    # ./../../services/gnome/gnome.nix
    ./../../services/plasma6/plasma6.nix
    ./../../services/jellyfin-nvidia/jellyfin.nix
    # ./../../services/nginx/nginx.nix
  ];

  boot = {
    supportedFilesystems = ["zfs"];
    # kernelPackages = unstablePkgs.linuxPackages_6_12;
  };

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
        8090
        45876
      ];
      allowedUDPPorts = [
        2049
        111
      ];
    };
  };

    users.users.${userSettings.username} = {
    hashedPassword = lib.mkForce "$6$a5oZjDb6.lIXkAeY$Y6yL2.wqgIYeRvNYv2no2NOgqTkWAifpw8eREkePeVUJTSEpKEqdBhAwGrM2bL8Zhe9bne2xmCX7dvW7IlwWb0";
  };

  services = {
    printing.enable = true;
    zfs = {
      autoScrub = {
        enable = true;
        interval = "weekly";};
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
    code-server = {
      enable = true;
    };
    stirling-pdf = {
      enable = true;
    };
    wiki-js = {
      enable = true;
      settings.db.host = "golmsten";
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
      code-server
      element-desktop
      freecad-wayland
      grsync
      nfs-utils
      nh
      nixpkgs-fmt
      spice-vdagent
      steam-run
      stirling-pdf
      stremio
      virt-manager
      virt-viewer
      zed-editor
    # Arduino stuff
      esptool
      esptool-ck
      python3
    ])
    ++ (with unstablePkgs; [
    # ollama
    # fabric-ai
    ]);

  system.stateVersion = "24.05"; # DO NOT CHANGE!!!
}
