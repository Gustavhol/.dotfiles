{ pkgs, unstablePkgs, lib, inputs, ... }:

{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  networking = {
    firewall = { 
      allowedTCPPortRanges = [ 
        { from = 25565; to = 25565; } # Java edition
        { from = 19132; to = 19132; } # Bedrock
      ];  
      allowedUDPPortRanges = [ 
        { from = 19132; to = 19132; } # Bedrock
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
        whitelist = {/* */};

        symlinks = {
          # Fetching from the internet
          "mods" = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
            Geyser = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/wKkoqHrH/versions/AVuBix2l/Geyser-Spigot.jar"; sha512 = "09a4644cff6af2c5305296ed0d5db0cd7e98325e51bdfaeb3e2a99893c90f2243d3b0cd4443eb391567dd382d539b95768f1bd655c63042fbcae2651ff50dbfe"; };
            Floodgate = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/bWrNNfkb/versions/wPa1pHZJ/Floodgate-Fabric-2.2.4-b36.jar"; sha512 = "fd347e3e6fce95f57c83fa3d1e130d460d1ee244efd6eda8a788a837542f12b8e6e6a8e57a3379dcf45bd5cc3ea88b4d951862747909688000320f60d825ffb6"; };
           });
        };
      };
    };
  };

  # ...
}