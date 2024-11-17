{config, pkgs, lib, ...}:

{
  networking = {
    firewall = { 
      enable = true;
      allowedTCPPorts = [
        3456
      ];
    };   
  };
  services = {
    vikunja = {
      enable = true;
      port = 3456;
      database = {
        type = "postgres";
        user = "vikunja";
        database = "vikunja";
        host= "/run/postgresql";
      };
      frontendHostname = "vikunja.holmstens.com";
      frontendScheme = "https";
      settings = {
        service = {
          motd = "Testmeddelande";
          timezone = "Europe/Stockholm";
        };
        auth = {
          local = {
            enabled = true;
          };
        };
      };
    };
    postgresql = {
      enable = true;
      package = pkgs.postgresql_16;
      ensureDatabases = [ "vikunja" ];
      ensureUsers = [
          {
              name = "vikunja";
              ensureDBOwnership = true;
          }
      ];
    };
  };

  systemd = {
    services = {
      vikunja-api = {
        serviceConfig = {
          DynamicUser = lib.mkForce false;
          User = "vikunja";
          Group = "vikunja";
        };
      };
      vikunja-db-backup = {
        description = "Backup Vikunja PostgreSQL Database";
        after = [ "postgresql.service" ];
        serviceConfig = {
          ExecStart = "${pkgs.postgresql_16}/bin/pg_dump --file=/var/backups/vikunja-db-backup.sql --username=vikunja --host=/run/postgresql --format=custom vikunja";
          User = "vikunja";
          Group = "vikunja";
        };
      #  wantedBy = [ "multi-user.target" ];
      };
      set-backup-dir-permissions = {
        description = "Ensure /var/backups is owned by the vikunja user";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "/bin/sh -c '${pkgs.coreutils}/bin/chown vikunja:vikunja /var/backups && ${pkgs.coreutils}/bin/chmod 0755 /var/backups'";
          Type = "oneshot";
          RemainAfterExit = true;
        };
      };
    };
    timers.vikunja-db-backup-timer = {
      description = "Run Vikunja DB Backup Daily";
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
  };

  users.users.vikunja = {
    description = "Vikunja Service";
    createHome = false;
    group = "vikunja";
    isSystemUser = true;
  };

  users.groups.vikunja = { };
}