# Drone footage library mounted from probook over NFSv4, via Tailscale.
# Source on probook: /home/gustav/footage-h264 - a symlink farm containing
# only the H.264 transcodes (originals are HEVC Main10 @120fps, which a
# Tizen TV will not direct-play). Regenerate after transcoding with:
#   ~/scripts/update-footage-farm.sh   (on probook)
# Uses the Tailscale address, not LAN 192.168.1.125: the router isolates WiFi
# clients from wired ones (ARP resolves, ICMP+TCP dropped). Tailscale still
# negotiates a direct path, so throughput is unaffected.
# Read-only: Jellyfin never writes to media.
{ config, pkgs, lib, ... }:

{
  # NOTE: nixpkgs 25.11 defines no NFS *client* option - only services.nfs.server
  # (see nixos/modules/services/network-filesystems/nfsd.nix). The client tools
  # (mount.nfs) come from nfs-utils, which is already in
  # environment.systemPackages in profiles/golmsten/default.nix.

  fileSystems."/mnt/probook-footage" = {
    device = "100.111.21.56:/home/gustav/footage-h264";
    fsType = "nfs4";
    options = [
      "ro"                     # Jellyfin only reads media
      "nfsvers=4.1"            # v4 has built-in locking; v3 needs statd/lockd
      "_netdev"                # network fs: systemd ordering hint
      "nofail"                 # don't block boot if probook is off/asleep
      "x-systemd.automount"    # mount lazily on first access, not at boot
      "x-systemd.idle-timeout=600"  # drop the mount after 10 min idle
      "noatime"                # no atime writes on media
      "nconnect=8"             # multiple TCP conns per mount: better throughput
    ];
  };

  # Mountpoint must exist before the automount unit uses it.
  systemd.tmpfiles.rules = [
    "d /mnt/probook-footage 0755 root root -"
  ];

  # NFS sec=sys maps client UID/GID directly onto file ownership. The footage
  # on probook is owned by uid 1000 (gustav) / gid 1000 (gustav). golmsten's
  # own gustav is also uid 1000 but gid 100 (users) - so run the jellyfin
  # service as uid 1000 with primary gid 1000 to get a "other" match on
  # probook's 0644/0755 files without needing root or ACLs on probook.
  users.users.jellyfin = {
    uid = 1000;
    group = "nfs-footage";   # gid 1000, matching probook's gustav
    description = "Jellyfin media server (NFS footage access)";
    extraGroups = [ "video" ];   # hardware accel if transcoding is ever needed
  };

  # gid 1000 matches probook's gustav group, so sec=sys file ownership lines up.
  users.groups.nfs-footage = { gid = 1000; };
}
