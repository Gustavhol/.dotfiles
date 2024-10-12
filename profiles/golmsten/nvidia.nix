{ config, pkgs, ... }:

{
  hardware = {
    nvidia = {
      modesetting.enable = true;
      package = pkgs.linuxPackages.nvidiaPackages.stable;
      nvidiaSettings = true;
    };
  };
  
  services.xserver = {
    videoDrivers = [ "nvidia" ];
  };

  environment.systemPackages = with pkgs; [
    cudatoolkit
    nvtopPackages.nvidia
  ];
}