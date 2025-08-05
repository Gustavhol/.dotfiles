{ config, pkgs, ... }:

{
  services.samba = {
    enable      = true;
    openFirewall = true;  # opens ports 137, 138, 139, 445 in NixOS’s firewall :contentReference[oaicite:0]{index=0}

    settings = {
      # Global smb.conf [global] section
      global = {
        security             = "user";           # require a username but we'll map unknown to guest
        workgroup            = "WORKGROUP";      # adjust to your Windows workgroup if needed
        "guest account"      = "nobody";         # unprivileged guest user
        "map to guest"       = "Bad User";       # unknown users become guest
        interfaces           = "lo 192.168.1.9"; # bind smbd only to localhost + this IP
        "bind interfaces only" = "yes";
      };

      # Define a share named "Music"
      Music = {
        path          = "/data/music";
        browseable    = "yes";    # show in network browse lists
        "read only"   = "yes";    # prevent writes
        "guest ok"    = "yes";    # allow guest access
        "create mask" = "0644";   # files created (if any) get these perms
        "directory mask" = "0755";# directories (if any) get these perms
        comment       = "Music share for Music Assistant";
      };
    };
  };
}
