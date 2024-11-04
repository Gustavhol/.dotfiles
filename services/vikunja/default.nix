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

  systemd.services.vikunja-api = {
    serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "vikunja";
      Group = "vikunja";
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