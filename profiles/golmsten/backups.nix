{ config, pkgs, ... }:

{
  # Ensure that rsync, curl (and bash) are available.
  environment.systemPackages = with pkgs; [ rsync curl ];

  # Deploy the backup script as /etc/backup.sh.
  environment.etc."backup.sh" = {
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      # Set the directory you want to backup.
      SOURCE_DIR="/data/nextcloud_backup/borg"  # <-- Replace with your actual source directory
      
      # Destination in the form "user@host:/path". (Assumes SSH key auth is set up.)
      DEST="root@100.66.227.91:/mnt/backups/nextcloud_aio"
      
      # Run rsync over ssh.
      OUTPUT=$(rsync -a -e ssh "${SOURCE_DIR}/" "${DEST}/" 2>&1)
      if [ $? -ne 0 ]; then
          curl -d "Nextcloud backup failed: ${OUTPUT}" https://ntfy.sh/holmstenxyz
          exit 1
      fi
    '';
    mode = "0755";
  };

  # Define a systemd service that runs the backup script.
  systemd.services.backup = {
    description = "Daily backup via rsync";
    serviceConfig = {
      # Use the bash from pkgs to run the script.
      ExecStart = "${pkgs.bash}/bin/bash /etc/backup.sh";
      # Optionally, you can add more settings (like User=, Environment=, etc.) if needed.
    };
  };

  # Define a systemd timer that triggers the backup service every night at 00:30.
  systemd.timers.backup = {
    description = "Timer for daily backup at 05:30";
    timerConfig = {
      OnCalendar = "*-*-* 05:30:00";
      Persistent = true;
    };
    wantedBy = [ "timers.target" ];
    service = "backup.service";
  };
}
