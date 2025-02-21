{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [rsync curl];

  environment.etc = {
    "backup-nextcloud.sh" = {
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail

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
    # "backup-immich-db.sh" = {
    #   text = ''
    #     #!/usr/bin/env bash
    #     set -euo pipefail

    #     # Disable 'errexit' so we can capture rsync's exit code.
    #     set +e
    #     OUTPUT=$(rsync -a -vv -e ssh /data/immich_backup/db_dumps root@100.66.227.91:/mnt/backups/immich_db 2>&1)
    #     EXIT_CODE=$?
    #     set -e

    #     # Prepend a label so that the output never starts with a dash.
    #     if [ "${"$"}{EXIT_CODE}" -ne 0 ]; then
    #         curl -d "Immich DB backup failed: [rsync error] ${"$"}{OUTPUT}" https://ntfy.sh/holmsten-backup
    #         exit "${"$"}{EXIT_CODE}"
    #     fi
    #   '';
    #   mode = "0755";
    # };
    "backup-immich.sh" = {
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail

        # Disable 'errexit' so we can capture rsync's exit code.
        set +e
        OUTPUT=$(rsync -a -vv -e ssh /data/immich/photos root@100.66.227.91:/mnt/backups/immich_data 2>&1)
        EXIT_CODE=$?
        set -e

        # Prepend a label so that the output never starts with a dash.
        if [ "${"$"}{EXIT_CODE}" -ne 0 ]; then
            curl -d "Immich Data backup failed: [rsync error] ${"$"}{OUTPUT}" https://ntfy.sh/holmsten-backup
            exit "${"$"}{EXIT_CODE}"
        fi
      '';
      mode = "0755";
    };
  };

  # Define a systemd service that runs the backup script.
  systemd.services = {
    backup-nextcloud = {
      description = "Daily Nextcloud-AIO backup via rsync over ssh on tailnet";
      serviceConfig = {
        ExecStart = "${pkgs.bash}/bin/bash /etc/backup-nextcloud.sh";
        Environment = "PATH=/run/current-system/sw/bin:/usr/bin:/bin HOME=/root";
      };
    };
    # backup-immich-db = {
    #   description = "Daily Immich DB backup via rsync over ssh on tailnet";
    #   serviceConfig = {
    #     ExecStart = "${pkgs.bash}/bin/bash /etc/backup-immich-db.sh";
    #     Environment = "PATH=/run/current-system/sw/bin:/usr/bin:/bin HOME=/root";
    #   };
    # };
    backup-immich = {
      description = "Daily Immich data backup via rsync over ssh on tailnet";
      serviceConfig = {
        ExecStart = "${pkgs.bash}/bin/bash /etc/backup-immich.sh";
        Environment = "PATH=/run/current-system/sw/bin:/usr/bin:/bin HOME=/root";
      };
    };
  };

  systemd.timers = {
    backup-nextcloud = {
      description = "Timer for daily backup at 05:00";
      timerConfig = {
        OnCalendar = "*-*-* 05:00:00";
        Persistent = true;
      };
      wantedBy = ["timers.target"];
    };
    # backup-immich-db = {
    #   description = "Timer for daily backup at 01:30";
    #   timerConfig = {
    #     OnCalendar = "*-*-* 01:30:00";
    #     Persistent = true;
    #   };
    #   wantedBy = ["timers.target"];
    # };
    backup-immich = {
      description = "Timer for daily backup at 02:40";
      timerConfig = {
        OnCalendar = "*-*-* 02:40:00";
        Persistent = true;
      };
      wantedBy = ["timers.target"];
    };
  };
}
