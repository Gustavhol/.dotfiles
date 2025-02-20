{
  config,
  pkgs,
  ...
}: {
  # Ensure that rsync, curl (and bash) are available.
  environment.systemPackages = with pkgs; [rsync curl];

  # Deploy the backup script as /etc/backup.sh.
  environment.etc."backup-nextcloud.sh" = {
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      # Send a test message to confirm ntfy is working.
      curl -d "Test Message" https://ntfy.sh/holmstenxyz

      # Disable 'errexit' so we can capture rsync's exit code.
      set +e
      OUTPUT=$(rsync -a -vv -e ssh /data/nextcloud_backup/borg root@100.66.227.91:/mnt/backups/nextcloud_aio 2>&1)
      EXIT_CODE=$?
      set -e

      # Prepend a label so that the output never starts with a dash.
      if [ "${"$"}{EXIT_CODE}" -ne 0 ]; then
          curl -d "Nextcloud backup failed: [rsync error] ${"$"}{OUTPUT}" https://ntfy.sh/holmsten-backup
          exit "${"$"}{EXIT_CODE}"
      fi
    '';
    mode = "0755";
  };

  # Define a systemd service that runs the backup script.
  systemd.services = {
    backup-nextcloud = {
      description = "Daily nextcloud-aio backup via rsync over ssh on tailnet";
      serviceConfig = {
        # Use the bash from pkgs to run the script.
        ExecStart = "${pkgs.bash}/bin/bash /etc/backup-nextcloud.sh";
        Environment = "PATH=/run/current-system/sw/bin:/usr/bin:/bin HOME=/root";
        # Optionally, you can add more settings (like User=, Environment=, etc.) if needed.
      };
    };
  };

  systemd.timers = {
    backup-nextcloud = {
      description = "Timer for daily backup at 05:30";
      timerConfig = {
        OnCalendar = "*-*-* 05:30:00";
        Persistent = true;
      };
      wantedBy = ["timers.target"];
    };
  };
}
