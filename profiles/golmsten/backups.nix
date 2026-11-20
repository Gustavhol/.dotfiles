{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [rsync curl];

  # Destinations:
  #   immich   (photos + Postgres dumps) -> elitedesk  100.66.227.91  /mnt/backups
  #   nextcloud AIO borg repository      -> docker     100.90.17.92   /primpool/nextcloud_aio
  # docker's /primpool is docker's own ZFS pool (primpool), imported and mounted inside that VM.
  environment.etc = {
    "backup-nextcloud.sh" = {
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail

        # Disable 'errexit' so we can capture rsync's exit code.
        set +e
        rsync -a -e "ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new" \
          /data/nextcloud_backup/borg root@100.90.17.92:/primpool/nextcloud_aio \
          > /tmp/backup-nextcloud.log 2>&1
        EXIT_CODE=$?
        set -e

        # Alert with only the TAIL of the log. Never hand the whole rsync log to curl as a single
        # argument: megabytes in one argv entry fail with "Argument list too long" (exit 126), so the
        # alert itself becomes the failure and the outage goes unreported. That is how these backups
        # stayed broken and unannounced for three months (Daily 2026-11-19).
        if [ "$EXIT_CODE" -ne 0 ]; then
            curl -s -d "Nextcloud backup failed: [rsync exit $EXIT_CODE] $(tail -c 1500 /tmp/backup-nextcloud.log)" \
              https://ntfy.sh/holmsten-backup || true
            exit "$EXIT_CODE"
        fi
      '';
      mode = "0755";
    };
    # Immich Postgres dumps. This job was commented out, which left the photos unrestorable: 226G of
    # photos with no database does not make a working Immich.
    "backup-immich-db.sh" = {
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail

        set +e
        rsync -a -e "ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new" \
          /data/immich_backup/db_dumps root@100.66.227.91:/mnt/backups/immich_db \
          > /tmp/backup-immich-db.log 2>&1
        EXIT_CODE=$?
        set -e

        if [ "$EXIT_CODE" -ne 0 ]; then
            curl -s -d "Immich DB backup failed: [rsync exit $EXIT_CODE] $(tail -c 1500 /tmp/backup-immich-db.log)" \
              https://ntfy.sh/holmsten-backup || true
            exit "$EXIT_CODE"
        fi
      '';
      mode = "0755";
    };
    "backup-immich.sh" = {
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail

        set +e
        rsync -a -e "ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new" \
          /data/immich/photos root@100.66.227.91:/mnt/backups/immich_data \
          > /tmp/backup-immich.log 2>&1
        EXIT_CODE=$?
        set -e

        if [ "$EXIT_CODE" -ne 0 ]; then
            curl -s -d "Immich Data backup failed: [rsync exit $EXIT_CODE] $(tail -c 1500 /tmp/backup-immich.log)" \
              https://ntfy.sh/holmsten-backup || true
            exit "$EXIT_CODE"
        fi
      '';
      mode = "0755";
    };
  };

  systemd.services = {
    backup-nextcloud = {
      description = "Daily Nextcloud-AIO borg repository backup via rsync over ssh on tailnet -> docker";
      serviceConfig = {
        ExecStart = "${pkgs.bash}/bin/bash /etc/backup-nextcloud.sh";
        Environment = "PATH=/run/current-system/sw/bin:/usr/bin:/bin HOME=/root";
      };
    };
    backup-immich-db = {
      description = "Daily Immich Postgres dump backup via rsync over ssh on tailnet -> elitedesk";
      serviceConfig = {
        ExecStart = "${pkgs.bash}/bin/bash /etc/backup-immich-db.sh";
        Environment = "PATH=/run/current-system/sw/bin:/usr/bin:/bin HOME=/root";
      };
    };
    backup-immich = {
      description = "Daily Immich photo backup via rsync over ssh on tailnet -> elitedesk";
      serviceConfig = {
        ExecStart = "${pkgs.bash}/bin/bash /etc/backup-immich.sh";
        Environment = "PATH=/run/current-system/sw/bin:/usr/bin:/bin HOME=/root";
      };
    };
  };

  systemd.timers = {
    backup-nextcloud = {
      description = "Timer for the daily Nextcloud backup at 06:00";
      timerConfig = {
        OnCalendar = "*-*-* 06:00:00";
        Persistent = true;
      };
      wantedBy = ["timers.target"];
    };
    backup-immich-db = {
      description = "Timer for the daily Immich DB backup at 01:30";
      timerConfig = {
        OnCalendar = "*-*-* 01:30:00";
        Persistent = true;
      };
      wantedBy = ["timers.target"];
    };
    backup-immich = {
      description = "Timer for the daily Immich data backup at 02:40";
      timerConfig = {
        OnCalendar = "*-*-* 02:40:00";
        Persistent = true;
      };
      wantedBy = ["timers.target"];
    };
  };
}
