{ pkgs ? import <nixpkgs> { } }:

pkgs.buildGoModule {
  pname = "control-http-home";
  version = "1.0.0";
  src = ./.;
  vendorHash = null;
  doCheck = false;
}
