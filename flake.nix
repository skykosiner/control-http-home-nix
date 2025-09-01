{
  description = "Nix flake for the control-http-home daemon";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      systems = flake-utils.lib.defaultSystems;

      perSystem = system:
        let
          pkgs = import nixpkgs { inherit system; };

          daemonPkg = pkgs.callPackage ./default.nix { };
          module = import ./module.nix {
            inherit pkgs;
            lib = pkgs.lib;
          };
        in { packages.control-http-home = daemonPkg; };

      anyPkgs = import nixpkgs { system = "x86_64-linux"; };
    in {
      nixosModules.default = import ./module.nix {
        pkgs = anyPkgs;
        lib = anyPkgs.lib;
      };
    } // flake-utils.lib.eachSystem systems perSystem;
}
