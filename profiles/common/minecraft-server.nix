{ pkgs, lib, inputs, ... }:

{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    
    # package = pkgs.minecraft-server-1-12;
    dataDir = "/var/lib/someotherdir";

    servers = {
      skog = {
        enable = true;
        package = pkgs.paperServers.paper-1_21;

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
        # let
        #   modpack = (pkgs.fetchPackwizModpack {
        #     url = "https://github.com/Misterio77/Modpack/raw/0.2.9/pack.toml";
        #     packHash = "sha256-L5RiSktqtSQBDecVfGj1iDaXV+E90zrNEcf4jtsg+wk=";
        #   })
        # in
          # Modpack example
          # "mods" = "${modpack}/mods";

          # Directories
          # "mods" = ./mods;

          # Fetching from the internet
           "mods" = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
             Geyser = fetchurl { url = "https://cdn.modrinth.com/data/wKkoqHrH/versions/AVuBix2l/Geyser-Spigot.jar"; sha512 = "09a4644cff6af2c5305296ed0d5db0cd7e98325e51bdfaeb3e2a99893c90f2243d3b0cd4443eb391567dd382d539b95768f1bd655c63042fbcae2651ff50dbfe"; };
             Floodgate = fetchurl { url = "https://cdn.modrinth.com/data/bWrNNfkb/versions/wPa1pHZJ/Floodgate-Fabric-2.2.4-b36.jar"; sha512 = "fd347e3e6fce95f57c83fa3d1e130d460d1ee244efd6eda8a788a837542f12b8e6e6a8e57a3379dcf45bd5cc3ea88b4d951862747909688000320f60d825ffb6"; };
          #   Starlight = fetchurl { url = "https://cdn.modrinth.com/data/H8CaAYZC/versions/XGIsoVGT/starlight-1.1.2%2Bfabric.dbc156f.jar"; sha512 = "6b0e363fc2d6cd2f73b466ab9ba4f16582bb079b8449b7f3ed6e11aa365734af66a9735a7203cf90f8bc9b24e7ce6409eb04d20f84e04c7c6b8e34f4cc8578bb"; };
          #   Lithium = fetchurl { url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/ZSNsJrPI/lithium-fabric-mc1.20.1-0.11.2.jar"; sha512 = "d1b5c90ba8b4879814df7fbf6e67412febbb2870e8131858c211130e9b5546e86b213b768b912fc7a2efa37831ad91caf28d6d71ba972274618ffd59937e5d0d"; };
          #   FerriteCore = fetchurl { url = "https://cdn.modrinth.com/data/uXXizFIs/versions/ULSumfl4/ferritecore-6.0.0-forge.jar"; sha512 = "e78ddd02cca0a4553eb135dbb3ec6cbc59200dd23febf3491d112c47a0b7e9fe2b97f97a3d43bb44d69f1a10aad01143dcd84dc575dfa5a9eaa315a3ec182b37"; };
          #   Krypton = fetchurl { url = "https://cdn.modrinth.com/data/fQEb0iXm/versions/jiDwS0W1/krypton-0.2.3.jar"; sha512 = "92b73a70737cfc1daebca211bd1525de7684b554be392714ee29cbd558f2a27a8bdda22accbe9176d6e531d74f9bf77798c28c3e8559c970f607422b6038bc9e"; };
          #   LazyDFU = fetchurl { url = "https://cdn.modrinth.com/data/hvFnDODi/versions/0.1.3/lazydfu-0.1.3.jar"; sha512 = "dc3766352c645f6da92b13000dffa80584ee58093c925c2154eb3c125a2b2f9a3af298202e2658b039c6ee41e81ca9a2e9d4b942561f7085239dd4421e0cce0a"; };
          #   C2ME = fetchurl { url = "https://cdn.modrinth.com/data/VSNURh3q/versions/t4juSkze/c2me-fabric-mc1.20.1-0.2.0%2Balpha.10.91.jar"; sha512 = "562c87a50f380c6cd7312f90b957f369625b3cf5f948e7bee286cd8075694a7206af4d0c8447879daa7a3bfe217c5092a7847247f0098cb1f5417e41c678f0c1"; };
           });
        };
      };
      # vanilla = {
      #   enable = true;
      #   package = pkgs.vanillaServers.vanilla-1_21
      # };
    };
  };

  # ...
}