{
  config,
  pkgs,
  ...
}: {
  home.packages = [pkgs.vscode];

  programs.vscode = {
    enable = true;

    profiles.default.extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      jnoortheen.nix-ide
      # william-voyek.vscode-nginx
      # teclado.vscode-nginx-formatter
      tailscale.vscode-tailscale
      ms-python.python
      ms-vscode.cpptools
      eamodio.gitlens
      ms-azuretools.vscode-docker
      esbenp.prettier-vscode
      dbaeumer.vscode-eslint
    ];

    profiles.gustav.userSettings = {
      "nix" = {
        "enableLanguageServer" = true;
        "serverPath" = "nixd";
        "formatterPath" = "alejandra";
        "serverSettings" = {
          "nixd" = {
            "formatting" = {
              "command" = ["alejandra"];
            };
            "options" = {
              "nixos" = {
                "expr" = "(builtins.getFlake \"/home/gustav/.dotfiles\").nixosConfigurations.golmsten.options";
              };
              "home_manager" = {
                "expr" = "(builtins.getFlake \"/home/gustav/.dotfiles\").homeConfigurations.gustav.options";
              };
            };
          };
        };
      };

      "git.autofetch" = true;
      "git.confirmSync" = false;
      "[nix]" = {
        "editor.formatOnSave" = true;
      };
      "editor.fontSize" = 13;
    };
  };
}
