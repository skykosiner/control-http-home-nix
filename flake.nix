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

        module = import ./module.nix { inherit pkgs daemonPkg; };
      in {
        packages.control-http-home = daemonPkg;
        nixosModules.default = module;
      });
}
