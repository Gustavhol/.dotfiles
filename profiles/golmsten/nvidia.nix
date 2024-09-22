{ config, pkgs, ... }:

{
  hardware.nvidia = {
    nvidiaDriver = true;
    nvidiaPackages = with pkgs.linuxPackages; nvidiaPackages.cudatoolkit;
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    videoDrivers = [ "nvidia" ];
  };

  services.xserver = {
    enable = true;
    layout = "us";  # Set your preferred keyboard layout
    videoDrivers = [ "nvidia" ];
  };

  environment.systemPackages = with pkgs; [
    cudatoolkit
    nvidia_x11  # NVIDIA X11 driver for graphics
  ];
}