{
  description = "Nix flake for the control-http-home daemon";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        daemonPkg = pkgs.callPackage ./default.nix { };

      in {
        # Export the package so it can be used directly if needed
        packages.control-http-home = daemonPkg;

        # Export the NixOS module so it can be imported by another flake
        nixosModules.control-http-home = import ./module.nix {
          inherit pkgs;
          inherit daemonPkg;
        };
      });
}
