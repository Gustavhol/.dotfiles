{
  pkgs,
  unstablePkgs,
  lib,
  inputs,
  ...
}: {
  imports = [inputs.nix-minecraft.nixosModules.minecraft-servers];
  # nixpkgs.overlays = [inputs.nix-minecraft.overlay];

  networking = {
    firewall = {
      allowedTCPPortRanges = [
        {
          from = 25565;
          to = 25565;
        } # Java edition
        {
          from = 19132;
          to = 19132;
        } # Bedrock
      ];
      allowedUDPPortRanges = [
        {
          from = 19132;
          to = 19132;
        } # Bedrock
      ];
    };
  };

  services.minecraft-servers = {
    enable = true;
    eula = true;

    # package = pkgs.minecraft-server-1-12;
    dataDir = "/var/lib/someotherdir";

    servers = {
      skog = {
        enable = true;
        package = unstablePkgs.papermc;
        jvmOpts = "-Xmx10G -Xms10G";

        serverProperties = {
          gamemode = "creative";
          difficulty = "hard";
          simulation-distance = 10;
          level-seed = "4";
          openFirewall = true;
          server-port = 25565;
        };
        whitelist = {
          /**/
        };

        symlinks = {
          # Fetching from the internet
          "mods" = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
            Geyser = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/wKkoqHrH/versions/AVuBix2l/Geyser-Spigot.jar";
              sha512 = "09a4644cff6af2c5305296ed0d5db0cd7e98325e51bdfaeb3e2a99893c90f2243d3b0cd4443eb391567dd382d539b95768f1bd655c63042fbcae2651ff50dbfe";
            };
            Floodgate = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/bWrNNfkb/versions/wPa1pHZJ/Floodgate-Fabric-2.2.4-b36.jar";
              sha512 = "fd347e3e6fce95f57c83fa3d1e130d460d1ee244efd6eda8a788a837542f12b8e6e6a8e57a3379dcf45bd5cc3ea88b4d951862747909688000320f60d825ffb6";
            };
            ViaBackwards = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/NpvuJQoq/versions/SPrE8VVb/ViaBackwards-5.0.4.jar";
              sha512 = "b793427a9ca6b69f1d9c873f04218da7dcdcd45784a5e8d7c64100b33385e6e174fbc8a8457310e5dc3787d45253cfe4dade3a61a6f3d257a3b9b170643c5b43";
            };
            ViaVersion = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/P1OZGk5p/versions/gCeZYBfA/ViaVersion-5.0.5.jar";
              sha512 = "b3ab397291c6eed4f0cb201dceaa20c5a79e00e33f8fdc3f0cc7b82bd41130d32f5a4381f7135b9d1e0ce79ad2449fdc5c84f4e14a86ede0da6077a7d4eacb53";
            };
          });
        };
      };
    };
  };

  # ...
}
