{ config, pkgs, ... }:

{
  home.packages = [ pkgs.zsh ];
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autocd = true;
    # something to get autocomplete to work. but i dont know how to format it
    # initExtra = [ ''
    #   bindkey "''${key[Up]}" up-line-or-search
    # '' ];
    shellAliases = {
      ls = "${pkgs.eza}/bin/eza --icons -l -T -L=1 --group-directories-first";
      la = "${pkgs.eza}/bin/eza --icons -l -a -h -T -L=1 --group-directories-first";
      tree = "${pkgs.eza}/bin/eza --color=auto --tree";
      grep = "grep --color=auto";
      ":q" = "exit";
      hmsf = "home-manager switch --flake .";
      nrsf = "sudo nixos-rebuild switch --flake .";
    };
    initContent = ''
      ssht() { ssh -t "$1" "export TERM=xterm-color; /bin/bash"; }
      sshz() { ssh -t "$1" "export TERM=xterm-color; /run/current-system/sw/bin/zsh"; }
      '';
    oh-my-zsh = {
      enable = true;
      plugins = [ 
        "npm"
        "sudo"
        "nvm"
        "git"
       ];
      theme = "robbyrussell";
    };
  };
}
