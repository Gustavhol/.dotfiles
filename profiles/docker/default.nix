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

  # 26.05 only adds the `zfs-import.target` edge when the mount is NOT `noauto`
  # (`lib.optional (!noauto) "zfs-import.target"` in nixpkgs zfs.nix). With `noauto` — which this
  # host needs, because ZFS's own `zfs mount -a` mounts the dataset and a systemd mount unit for the
  # same path races with it — nothing imported the pool at boot, so /primpool never mounted and the
  # containers started against an empty directory on the root filesystem: Docker creates a missing
  # bind-mount source, so open-webui initialised a fresh database and served it as if it were real
  # data. Re-adding the edge explicitly restores what 24.11 generated.
  # Do NOT drop `noauto` to fix this instead: verified 2026-11-20, systemd and zfs-mount.service then
  # both mount /primpool, `primpool.mount` fails, local-fs.target's dependency fails, and the host
  # drops to emergency mode.
  systemd.services."zfs-import-primpool".wantedBy = [ "zfs-import.target" ];

   fileSystems."/primpool" = {
     device = "primpool";
     fsType = "zfs";
     options = [ "zfsutil" "noauto" ];
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

  # Never let containers start against something that is not the pool. Docker creates a missing
  # bind-mount source, so an unmounted /primpool silently becomes an empty data directory and
  # open-webui initialises a fresh database and serves it (happened 2026-11-20). Ordered after
  # zfs-mount.service so the condition is evaluated once ZFS has actually mounted the dataset,
  # not in a race with it.
  systemd.services.docker = {
    after = [ "zfs-mount.service" ];
    unitConfig.ConditionPathIsMountPoint = "/primpool";
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
