{ config, pkgs, ... }:

{
  home.packages = [ pkgs.alacritty ];
  programs.alacritty = {
    enable = true;
    settings = {
    #  import = [ pkgs.alacritty-theme.gruvbox ];
      live_config_reload = true;
    #   colors = with config.colorScheme.colors; {
    #   bright = {
    #     black = "0x${base00}";
    #     blue = "0x${base0D}";
    #     cyan = "0x${base0C}";
    #     green = "0x${base0B}";
    #     magenta = "0x${base0E}";
    #     red = "0x${base08}";
    #     white = "0x${base06}";
    #     yellow = "0x${base09}";
    #   };
    #   cursor = {
    #     cursor = "0x${base06}";
    #     text = "0x${base06}";
    #   };
    #   normal = {
    #     black = "0x${base00}";
    #     blue = "0x${base0D}";
    #     cyan = "0x${base0C}";
    #     green = "0x${base0B}";
    #     magenta = "0x${base0E}";
    #     red = "0x${base08}";
    #     white = "0x${base06}";
    #     yellow = "0x${base0A}";
    #   };
    #   primary = {
    #     background = "0x${base00}";
    #     foreground = "0x${base06}";
    #   };
    # };
      colors = {
        normal = {
          black = "0x282c34";
          blue = "0x51afef";
          cyan = "0x46d9ff";
          green = "0x98be65";
          magenta = "0xc678dd";
          red = "0xff6c6b";
          white = "0xbbc2cf";
          yellow = "0xecbe7b";
        };
        primary = {
          background = "0x060607";
          foreground = "0xbbc2cf";
        };
      };
      font = {
        size = 11.0;
        normal = {
        family = "Hack Nerd Font";
        };
        offset = {
          x = 0;
          y = 1;
        };
      };
      window = {
        padding = {
          x = 5;
          y = 5;
        };
      };
    };
  };
}
