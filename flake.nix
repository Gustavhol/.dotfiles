{
  description = "Default flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.05";
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

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
  let
    system = "x86_64-linux";

    systemSettings = {
      inherit system;
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

    mkPkgs = nixpkgsSrc: import nixpkgsSrc {
      inherit system;
      config.allowUnfree = true;
      config.allowUnfreePredicate = _: true;
      overlays = [ inputs.alacritty-theme.overlays.default inputs.nix-minecraft.overlay ];
    };

    nixosSystem = hostname: username:
      let
        pkgs = mkPkgs nixpkgs;
        unstablePkgs = mkPkgs nixpkgs-unstable;
      in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit pkgs unstablePkgs systemSettings userSettings inputs;
            customArgs = {
              inherit hostname username pkgs unstablePkgs;
              nixvim = inputs.nixvim;
              nix-colors = inputs.nix-colors;
              vscode-server = inputs.vscode-server;
            };
          };
          modules = [
            ./profiles/${hostname}

            ({ pkgs, ... }: {
              boot.kernelPackages = pkgs.linuxPackages;
            })

            inputs.nixvim.nixosModules.nixvim
            inputs.vscode-server.nixosModules.default
          ];
        };

  in {
    nixosConfigurations = {
      elitedesk = nixosSystem "elitedesk" "gustav";
      starlite  = nixosSystem "starlite" "gustav";
      golmsten  = nixosSystem "golmsten" "gustav";
      docker    = nixosSystem "docker" "gustav";
    };

    homeConfigurations = {
      gustav = home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs nixpkgs;

        modules = [
          ./home/gustav.nix
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];

        extraSpecialArgs = {
          unstablePkgs = mkPkgs nixpkgs-unstable;
          inherit systemSettings userSettings inputs;
        };
      };
    };
  };
}
