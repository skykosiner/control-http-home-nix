{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.control-http-home;

  daemonPkg = pkgs.callPackage ./default.nix { };

  configJson = builtins.toJSON { commands = cfg.commands; };
in {
  options.services.control-http-home = {
    enable = mkEnableOption "control http home daemon";

    commands = mkOption {
      type = with types;
        listOf (submodule {
          options = {
            name = mkOption {
              type = types.str;
              description = "Name of the command.";
            };

            action = mkOption {
              type = types.str;
              description = "System command to execute.";
            };

            url = mkOption {
              type = types.str;
              description = "URL endpoint for the command.";
            };
          };
        });
      default = [ ];
      description = "List of HTTP command endpoints.";
    };
  };

  config = mkIf cfg.enable {
    users.groups.control-http-home = { };

    users.users.control-http-home = {
      isSystemUser = true;
      description = "Control HTTP Home daemon user";
      home = "/var/lib/control-http-home";
      shell = pkgs.bash;
      group = "control-http-home";
      extraGroups = [ "wheel" ]; # Allows sudo access if wheel is in sudoers
    };

    security.sudo.extraConfig = ''
      control-http-home ALL=(ALL) NOPASSWD: /bin/systemctl suspend
    '';

    environment.etc."control-http-home/config.json".text = configJson;

    systemd.services.control-http-home = {
      description = "Control HTTP Home Daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart =
          "${daemonPkg}/bin/control-http-home --config=/etc/control-http-home/config.json";
        Restart = "always";
        User = "control-http-home";
        DynamicUser = false;
      };
    };
  };
}
