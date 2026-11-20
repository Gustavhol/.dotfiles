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

  # A pool is imported at boot only when its mount is NOT `noauto`: the generated
  # `zfs-import-<pool>.service` picks up `zfs-import.target` via
  # `lib.optional (!noauto) "zfs-import.target"` (nixpkgs zfs.nix). With `noauto`, nothing pulls the
  # import in at boot, /primpool never mounts, and the containers start against an empty directory on
  # the root filesystem — Docker creates a missing bind-mount source — so open-webui initialises a
  # fresh database and serves that as if it were your data. That is exactly what happened on the
  # first 26.05 boot on 2026-11-20.
  # `boot.zfs.extraPools` does NOT fix this: it only adds pools to the generated-unit list, it does
  # not change the noauto condition.
   fileSystems."/primpool" = {
     device = "primpool";
     fsType = "zfs";
     options = [ "zfsutil" ];
   };

  networking = {
    hostName = "docker";
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
      nfs-utils
    ])
    ++ (with unstablePkgs; [
      ]);

  # programs.kdeconnect.enable = true;

  system.stateVersion = "24.11"; # DO NOT CHANGE!!!
}
