{ config, pkgs, ... }:

{
  home.packages = [ pkgs.zsh ];
  programs.zsh = {
    enable = true;
    shellAliases = {
      ls = "${pkgs.eza}/bin/eza --icons -l -T -L=1 --group-directories-first";
      la = "${pkgs.eza}/bin/eza --icons -l -a -h -T -L=1 --group-directories-first";
      tree = "${pkgs.eza}/bin/eza --color=auto --tree";
      grep = "grep --color=auto";
      ":q" = "exit";
      hmsf = "home-manager switch --flake .";
      nrsf = "sudo nixos-rebuild switch --flake .";
    };
  };
}