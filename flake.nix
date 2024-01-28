{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
    #nixpkgs.url = github:NixOS/nixpkgs/nixos-23.05;
    flake-utils.url = github:numtide/flake-utils;

    #home-manager = {
    #    url = "github:nix-community/home-manager/release-23.05";
    #    inputs.nixpkgs.follows = "nixpkgs";
    #};

    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , home-manager
    , nixos-hardware
    , ...
    }@inputs:
    let
      system = "aarch64-linux";
    in
    rec {
      images = {
        rpi4 = (self.nixosConfigurations.rpi4-hardware.extendModules {
          modules = [ 
            ({...}: { 
                imports = ["${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-new-kernel-no-zfs-installer.nix"];
                config = {
                    sdImage.imageBaseName = "rpi4-base";
                    sdImage.compressImage = false;
                };
            })
          ];
        }).config.system.build.sdImage;
      };

      nixosConfigurations = {

        rpi4 = nixpkgs.lib.nixosSystem {
          system = system;
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./rpi-4-base.nix
          ];
        };

        rpi4-hardware = nixpkgs.lib.nixosSystem {
          system = system;
          specialArgs = {
            inherit inputs;
          };
          modules = [
            nixos-hardware.nixosModules.raspberry-pi-4
            ./rpi-4-hardware.nix
            ./rpi-4-base.nix
            ./klipper.nix
          ];
        };


      };
    };
}
