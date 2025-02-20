{
  description = "Default flake";

  inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
      nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
      home-manager = {
        url = "github:nix-community/home-manager/release-24.11";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      nixvim = {
        url = "github:nix-community/nixvim/nixos-24.11";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      alacritty-theme.url = "github:alexghr/alacritty-theme.nix";
      nix-colors.url = "github:misterio77/nix-colors";
      vscode-server.url = "github:nix-community/nixos-vscode-server";
      firefox-addons = {
        url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      nix-minecraft.url = "github:Infinidoge/nix-minecraft";
  };

  outputs = { 
   self, 
   nixpkgs, 
   nixpkgs-unstable, 
   home-manager, 
   nixvim, 
   alacritty-theme, 
   nix-colors, 
   vscode-server, 
   firefox-addons,
   nix-minecraft,
   ... 
   }@inputs:
    let 
      inputs = { inherit nixpkgs nixpkgs-unstable home-manager nixvim alacritty-theme nix-colors vscode-server firefox-addons nix-minecraft; };
      
      genPkgs = system: import nixpkgs { inherit system; config.allowUnfree = true; config.allowUnfreePredicate = _: true; };
      genUnstablePkgs = system: import nixpkgs-unstable { inherit system; config.allowUnfree = true; config.allowUnfreePredicate = _: true; };
      
      systemSettings = {
        system = "x86_64-linux";
        timezone = "Europe/Stockholm";
        keymap = "sv-latin1";
        locale = "sv_SE.UTF-8";
      };

      userSettings = {
        username = "gustav";
        name = "Gustav";
        email = "gustav@holmstens.com";
        dotfilesdir = "~/.dotfiles";
        editor = "nvim";
        term = "alacritty";
      };

      nixosSystem = system: hostname: username:
        let
          pkgs = genPkgs system;
          unstablePkgs = genUnstablePkgs system;
        in
          nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit pkgs unstablePkgs systemSettings userSettings inputs;
              customArgs = {inherit system hostname username pkgs unstablePkgs nixvim nix-colors vscode-server; };
            };
            modules = [ 
              ./profiles/${hostname}
               ({ config, pkgs, ...}: {
          # install the overlay
                 nixpkgs.overlays = [ alacritty-theme.overlays.default ];
               })
              nixvim.nixosModules.nixvim
              vscode-server.nixosModules.default
              ];

            };
    in {
      nixosConfigurations = {
        elitedesk = nixosSystem "x86_64-linux" "elitedesk" "gustav";
        starlite = nixosSystem "x86_64-linux" "starlite" "gustav";
        golmsten = nixosSystem "x86_64-linux" "golmsten" "gustav";
        nix-nas = nixosSystem "x86_64-linux" "primpan" "gustav";
      # probook = nixosSystem "x86_64-linux" "probook" "gustav";
      };
      homeConfigurations = {
        gustav = home-manager.lib.homeManagerConfiguration {
          pkgs = genPkgs "x86_64-linux";
          modules = [ 
              ./home/gustav.nix

          ];
          extraSpecialArgs = {
            inherit inputs;
            unstablePkgs = genUnstablePkgs "x86_64-linux";
            inherit systemSettings;
            inherit userSettings;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          };
        };
      };
  };
   # };
}
