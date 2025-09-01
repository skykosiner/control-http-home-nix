{ pkgs, lib }:
let daemonPkg = pkgs.callPackage ./default.nix { };
in { config, ... }: {
  options.services.control-http-home = {
    enable = lib.mkEnableOption "control http home daemon";

    commands = lib.mkOption {
      type = with lib.types;
        listOf (submodule {
          options = {
            name = lib.mkOption {
              type = types.str;
              description = "Name of the command.";
            };

            action = lib.mkOption {
              type = types.str;
              description = "System command to execute.";
            };

            url = lib.mkOption {
              type = types.str;
              description = "URL endpoint for the command.";
            };
          };
        });
      default = [ ];
      description = "List of HTTP command endpoints.";
    };
  };

  config = lib.mkIf config.services.control-http-home.enable {
    environment.etc."control-http-home/config.json".text = builtins.toJSON {
      commands = config.services.control-http-home.commands;
    };

    systemd.services.control-http-home = {
      description = "Control HTTP Home Daemon (system service)";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ]; # ← system runlevel

      serviceConfig = {
        ExecStart =
          "${daemonPkg}/bin/control-http-home --config=/etc/control-http-home/config.json";

        Restart = "always";
        RestartSec = 2;
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };
  };
}
