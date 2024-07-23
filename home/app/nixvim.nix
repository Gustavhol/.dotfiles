{ self, ... }:
#{ config, pkgs, userSettings, ... }:

{
  programs.nixvim = {
    enable = true;
    colorschemes.onedark.enable = true;
  };
}