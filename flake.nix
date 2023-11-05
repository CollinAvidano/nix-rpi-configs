{
    description = "A very basic flake";

    inputs = {
        nixpkgs.url = github:NixOS/nixpkgs/nixos-23.05;
        flake-utils.url = github:numtide/flake-utils;

        home-manager = {
            url = "github:nix-community/home-manager/release-23.05";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    };

    outputs =
    { 
        self
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
            nixosConfigurations.rpi4 = nixpkgs.lib.nixosSystem {
                system = system;
                specialArgs = {
                    inherit inputs;
                    inherit system;
                };
                modules = [
                    ./rpi-4-base.nix
                    ./klipper.nix
                ];
            };
        };
}
