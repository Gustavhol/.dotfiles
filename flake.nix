{
  description = "Gustavs Nix flake (NixOS + Home-Manager)";

  inputs = {
    # Stable Nixpkgs for NixOS
    nixpkgs = { url = "github:NixOS/nixpkgs/nixos-25.11"; };

    # Unstable for occasional apps
    nixpkgs-unstable = { url = "github:NixOS/nixpkgs/nixos-unstable"; };

    # Home Manager standalone
    home-manager = {
      url                   = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Third-party NixOS modules
    nixvim = { url = "github:nix-community/nixvim/nixos-25.11"; inputs.nixpkgs.follows = "nixpkgs"; };
    vscode-server = { url = "github:nix-community/nixos-vscode-server"; inputs.nixpkgs.follows = "nixpkgs"; };

    # Overlays & themes
    alacritty-theme = { url = "github:alexghr/alacritty-theme.nix"; };
    nix-colors      = { url = "github:misterio77/nix-colors"; };

    # Firefox addons from NUR
    firefox-addons = {
      url                   = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Minecraft support
    nix-minecraft = { url = "github:Infinidoge/nix-minecraft"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = inputs@{ self
                   , nixpkgs, nixpkgs-unstable
                   , home-manager
                   , nixvim
                   , vscode-server
                   , alacritty-theme
                   , nix-colors
                   , firefox-addons
                   , nix-minecraft
                   , ... }:
  let
    system = "x86_64-linux";

    # Common NixOS options
    systemSettings = {
      inherit system;
      timezone = "Europe/Stockholm";
      keymap   = "sv-latin1";
      locale   = "sv_SE.UTF-8";
    };

    # User metadata
    userSettings = {
      username   = "gustav";
      name       = "Gustav";
      email      = "gustav@holmstens.com";
      dotfilesdir= "~/.dotfiles";
      editor     = "nvim";
      term       = "alacritty";
    };

    # Helper: import pkgs with unfree & overlays
    mkPkgs = src: import src {
      inherit system;
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
        permittedInsecurePackages = [
          "qtwebengine-5.15.19"
          "libsoup-2.74.3"
        ];
      };
      overlays = [
        alacritty-theme.overlays.default
        nix-minecraft.overlay
      ];
    };

    pkgs         = mkPkgs nixpkgs;
    unstablePkgs = mkPkgs nixpkgs-unstable;

    # Modules common to all NixOS hosts
    commonModules = [
      ({ config, pkgs, ... }: {
        # enable unfree at the module level too
        nixpkgs.config.allowUnfree = true;
        nixpkgs.config.allowUnfreePredicate = _: true;
        nixpkgs.config.permittedInsecurePackages = [
          # "qtwebengine-5.15.19"
          "libsoup-2.74.3"
        ];

        # custom kernel
        boot.kernelPackages = pkgs.linuxPackages;
      })
      nixvim.nixosModules.nixvim
      vscode-server.nixosModules.default
    ];

    # Helper to build each host
    mkHost = host: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        # inherit pkgs unstablePkgs systemSettings userSettings inputs;
        inherit unstablePkgs systemSettings userSettings inputs;
        customArgs = { inherit host; };  # if your profiles use "host"
      };
      modules = [
        ./profiles/${host}/default.nix
      ] ++ commonModules;
    };
  in {
    ################################################################
    # 1) NIXOS SYSTEMS
    ################################################################
    nixosConfigurations = {
      elitedesk = mkHost "elitedesk";
      starlite  = mkHost "starlite";
      golmsten  = mkHost "golmsten";
      docker    = mkHost "docker";
      probook	= mkHost "probook";
    };

    ################################################################
    # 2) HOME-MANAGER STANDALONE FOR 'gustav'
    ################################################################
    homeConfigurations = {
      gustav = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # This wrapper already loads the core Home-Manager module,
        # so you only list your custom home.nix.
        modules = [
          ./home/gustav.nix
        ];

        extraSpecialArgs = {
          inherit pkgs unstablePkgs systemSettings userSettings inputs system;
        };
      };
    };
  };
}
