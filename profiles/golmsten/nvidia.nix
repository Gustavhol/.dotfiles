{ config, pkgs, unstablePkgs, ... }:

{
  hardware = {
    nvidia = {
      modesetting.enable = true;
      package = pkgs.linuxPackages.nvidiaPackages.beta;
      nvidiaSettings = true;
      open = false;
    };
  };

  boot.kernelParams = [ "nvidia-drm.modeset=1" ];

  services.udev.extraRules = ''
    KERNEL=="card*", SUBSYSTEM=="drm", MODE="0666"
    KERNEL=="renderD*", SUBSYSTEM=="drm", MODE="0666"
  '';
  
  services.xserver = {
    videoDrivers = [ "nvidia" ];
  };

  environment.sessionVariables = {
  KWIN_DRM_USE_EGL_STREAMS = "0";  
  LIBVA_DRIVER_NAME = "dummy";
  __GL_GSYNC_ALLOWED = "0";
  __GL_VRR_ALLOWED = "0";
 };

  environment.systemPackages = with pkgs; [
    cudatoolkit
    nvtopPackages.nvidia
    nvidia-vaapi-driver
  ];
}