{ config, pkgs, unstablePkgs, ... }:

{
  hardware = {
    nvidia = {
      modesetting.enable = true;
      package = unstablePkgs.linuxPackages_6_12.nvidiaPackages.beta;
      nvidiaSettings = true;
      open = true;
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