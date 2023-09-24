{
    description = "A very basic flake";

    inputs = {
        nixpkgs.url = github:NixOS/nixpkgs/nixos-23.05;
        flake-utils.url = github:numtide/flake-utils;

        # home-manager = {
        #     url = "github:nix-community/home-manager/release-23.05";
        #     inputs.nixpkgs.follows = "nixpkgs";
        # };

        nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    };

    outputs =
        { self
        , nixpkgs
        , flake-utils
        , ...
        }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
        let
            pkgs = import nixpkgs {
                inherit system;
            };
        in
            rec {
                packages.nixosConfigurations = {
                    "nix-rpi-chiron" = nixpkgs.lib.nixosSystem {
                        system = "aarch64-linux";
                        specialArgs = {
                            inherit inputs;
                            inherit system;
                            inherit pkgs;
                        };
                        modules = [
                            ./rpi-base.nix
                            ./klipper.nix
                        ];
                    };
                };

                # packages.my-sd-card = packges.nixosConfigurations.nix-rpi-chiron.config.system.build.sdImage;
            }

    );

}
