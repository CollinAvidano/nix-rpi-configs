{
    description = "A very basic flake";

    inputs = {
        nixpkgs.url = github:NixOS/nixpkgs/nixos-23.05;
        flake-utils.url = github:numtide/flake-utils;

        # home-manager = {
        #     url = "github:nix-community/home-manager/release-23.05";
        #     inputs.nixpkgs.follows = "nixpkgs";
        # };

        # nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    };

    outputs =
        { self
        , nixpkgs
        , flake-utils
        , ...
        }@inputs:
        let
            overlays = [(final: prev: {
                nix-rpi-chiron = final.callpackage ./nix-rpi-chiron.nix {inherit inputs; };
            })];
        in
            { inherit overlays; } // flake-utils.lib.eachDefaultSystem (system: rec
            {
                legacyPackages = import nixpkgs { inherit system; inherit overlays; };
            })
    ;
}