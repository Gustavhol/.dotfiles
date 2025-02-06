{ config, pkgs, lib, ... }:

{
  ###### Let’s Encrypt/ACME settings ######
  # Make sure to adjust the email address and accept terms.
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "certbot@holmstens.com";
      webroot = "/var/lib/acme/acme-challenge";  # Add this globally
      server = "https://acme-staging-v02.api.letsencrypt.org/directory"; # Staging server
      # server = "https://acme-v02.api.letsencrypt.org/directory"; # Production server
    };
    # If you want separate certificate derivations for each domain
    # (instead of a single multi-SAN certificate), you can do that here:
    certs = {
      "cloud.holmstens.com" = {
      # webroot = "/var/lib/acme/acme-challenge";
      # listenHTTP = ":80";
      # webroot = null;
      };
      "photos.holmstens.com" = {
      # webroot = "/var/lib/acme/acme-challenge";
      # listenHTTP = ":80";
      # webroot = null;
      };
      "vikunja.holmstens.com" = {
      # webroot = "/var/lib/acme/acme-challenge";
      # listenHTTP = ":80";
      # webroot = null;
      };
      "ha.holmsten.xyz" = {
      # webroot = "/var/lib/acme/acme-challenge";
      # listenHTTP = ":80";
      # webroot = null;
      };
    };
  };

  networking.firewall.allowedTCPPorts = lib.mkForce [ 80 443 ];

  users.users.nginx.extraGroups = ["acme"];
  systemd.services.nginx.serviceConfig.SupplementaryGroups = [ "acme" ];

  ###### Nginx service configuration ######
  services.nginx = {
    enable = true;

    # Turn on recommended settings for compression/proxy, if desired
    recommendedGzipSettings   = true;
    recommendedProxySettings  = true;

  # Combine everything into a single httpConfig block
  httpConfig = ''
    map $http_upgrade $connection_upgrade {
      default upgrade;
      "" close;
    }

    # Optional: replicate your global SSL parameters here
    # (If you rely on NixOS defaults, you can omit these.)
    ssl_session_timeout 1d;
    ssl_session_cache shared:MozSSL:10m;
    ssl_session_tickets off;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
  '';

    virtualHosts = {

      ############################################################################
      # Nextcloud AIO (cloud.holmstens.com)
      ############################################################################
      "cloud.holmstens.com" = {
        # Enable Let’s Encrypt for this host
        enableACME = true;
        forceSSL   = true;  # automatically redirects HTTP -> HTTPS
        # useACMEHost = "cloud.holmstens.com";
        # sslTrustedCertificate = null; 
        # useACMEHost = null;

        locations = {
          "/.well-known/acme-challenge" = {
            root = "/var/lib/acme/acme-challenge";
            extraConfig = ''
            allow all;
            auth_basic off;
            proxy_pass off;
            try_files $uri =404;
          '';
          };
          "/" = {
            proxyPass = "http://192.168.1.9:11000";

            extraConfig = ''
              # Forward standard proxy headers
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Port $server_port;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-Scheme $scheme;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header Accept-Encoding "";
              proxy_set_header Host $host;

              # Handle large requests/timeouts
              client_body_buffer_size 512k;
              proxy_read_timeout 86400s;
              client_max_body_size 0;

              # WebSockets
              proxy_http_version 1.1;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection $connection_upgrade;
            '';
          };
        };
      };

      ############################################################################
      # Immich (photos.holmstens.com)
      ############################################################################
      "photos.holmstens.com" = {
        enableACME = true;
        forceSSL   = true;

        # This sets the max client upload size globally for this vhost
        extraConfig = ''
          client_max_body_size 50000M;
        '';
          locations = {
            "/.well-known/acme-challenge" = {
              root = "/var/lib/acme/acme-challenge";
              extraConfig = ''
              allow all;
              auth_basic off;
              proxy_pass off;
              try_files $uri =404;
            '';
            };
            "/" = {
              proxyPass = "http://192.168.1.9:2283";
              extraConfig = ''
                proxy_set_header Host              $http_host;
                proxy_set_header X-Real-IP         $remote_addr;
                proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;

                # WebSocket support
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "upgrade";
                proxy_redirect off;
              '';
            };
          };
      };

      ############################################################################
      # Vikunja (vikunja.holmstens.com)
      ############################################################################
      "vikunja.holmstens.com" = {
        enableACME = true;
        forceSSL   = true;

        locations = {
          "/.well-known/acme-challenge" = {
            root = "/var/lib/acme/acme-challenge";
            extraConfig = ''
            allow all;
            auth_basic off;
            proxy_pass off;
            try_files $uri =404;
          '';
          };
          # Root
          "/" = {
            proxyPass = "http://192.168.1.9:3456";
            # minimal extra config
          };

          # API
          "/api/v1" = {
            proxyPass = "http://192.168.1.9:3456";
            extraConfig = ''
              client_max_body_size 512M;
            '';
          };
        };
      };

      ############################################################################
      # Home Assistant (ha.holmsten.xyz)
      ############################################################################
      "ha.holmsten.xyz" = {
        enableACME = true;
        forceSSL   = true;

        # If you need proxy_buffering off globally for this host
        extraConfig = ''
          proxy_buffering off;
        '';

        locations = {
          "/.well-known/acme-challenge" = {
            root = "/var/lib/acme/acme-challenge";
            extraConfig = ''
            allow all;
            auth_basic off;
            proxy_pass off;
            try_files $uri =404;
          '';
          };
          # Main location
          "/" = {
            proxyPass = "http://192.168.1.38:8123";
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_pass_header Authorization;
              proxy_redirect http:// https://;
              proxy_http_version 1.1;
              proxy_set_header X-Real-IP         $remote_addr;
              proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";
            '';
          };

          # Websocket subpath
          "/api/websocket" = {
            proxyPass = "http://192.168.1.38:8123/api/websocket";
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_redirect http:// https://;
              proxy_http_version 1.1;
              proxy_set_header X-Real-IP         $remote_addr;
              proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";
            '';
          };
        };
      };
    };
  };
}
