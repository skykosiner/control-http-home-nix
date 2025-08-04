{ pkgs ? import <nixpkgs> { } }:

pkgs.buildGoModule {
  pname = "control-http-home";
  version = "1.0.0";
  src = ./control-http-home;
  vendorHash = null;
  doCheck = false;
}
