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
    ./samba.nix
    ./../common/common-nixos.nix
    ./../common/pipewire.nix
    # ./../../services/gnome/gnome.nix
    ./../../services/plasma6/plasma6.nix
    ./../../services/jellyfin-nvidia/jellyfin.nix
    # ./../../services/nginx/nginx.nix
  ];

  boot = {
    supportedFilesystems = ["zfs"];
    zfs.extraPools = [ "data" ];
    # kernelPackages = unstablePkgs.linuxPackages_6_12;
  };

  # fileSystems."/data" = {
  #   device = "data";
  #   fsType = "zfs";
  #   options = ["zfsutil" "noauto"];
  # };

  networking = {
    hostName = "golmsten";
    hostId = "336bf6d7";
    firewall = {
      enable = true;
      # 11000 nextcloud aio, 2283 immich, 8089 stirling-pdf, 3010 wiki-js,
      # 8090 published by a container (docker-proxy)
      allowedTCPPorts = [
        2049
        111
        3010
        8089
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

  # A static user rather than a DynamicUser, so PostgreSQL's peer authentication can map it to a
  # role of the same name over the local socket. That keeps the database password out of this
  # repository, which is public.
  users.users.wiki = {
    description = "Wiki.js Service";
    isSystemUser = true;
    group = "wiki";
  };

  users.groups.wiki = { };

  services = {
    printing.enable = true;
    zfs = {
      autoScrub = {
        enable = true;
        interval = "weekly";};
    };
    ollama = {
      enable = true;
      package = unstablePkgs.ollama-cuda;
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
      environment = { INSTALL_BOOK_AND_ADVANCED_HTML_OPS = "true"; SERVER_PORT = 8089; };
    };
    wiki-js = {
      enable = true;
      settings = {
        bindIP = "0.0.0.0";
        port = 3010;
        db = {
          type = "postgres";
          host = "/run/postgresql";
          user = "wiki";
          db = "wiki";
        };
      };
    };
    # The native Vikunja instance was retired on 2026-11-27: the board the agents use runs in
    # Docker, and the only thing the host still needs is a PostgreSQL cluster for wiki-js. The old
    # `vikunja` database and role are deliberately left on disk (dumped to /data/archive); these
    # ensure* settings only create, they never drop.
    postgresql = {
      enable = true;
      package = pkgs.postgresql_16;
      ensureDatabases = ["wiki"];
      ensureUsers = [
        {
          name = "wiki";
          ensureDBOwnership = true;
        }
      ];
    };
  };

  # wiki-js ships as a DynamicUser unit; override that so it runs as the static `wiki` user and
  # its StateDirectory is owned by a real account.
  systemd.services.wiki-js.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "wiki";
    Group = "wiki";
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
      # angryipscanner
      code-server
      dolphin-emu
      element-desktop
      freecad-wayland
      grsync
      nfs-utils
      nh
      nixpkgs-fmt
      rustdesk
      ryubing
      shipwright
      spice-vdagent
      steam-run
      stirling-pdf
      # stremio
      unrar
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
