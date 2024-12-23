{ config, pkgs, ... }:

{
  hardware = {
    nvidia = {
      modesetting.enable = true;
      package = pkgs.linuxPackages.nvidiaPackages.beta;
      nvidiaSettings = true;
    };
  };
  
  services.xserver = {
    videoDrivers = [ "nvidia" ];
  };

  environment.systemPackages = with pkgs; [
    cudatoolkit
    nvtopPackages.nvidia
    nvidia-vaapi-driver
  ];
}