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
    flake-utils.lib.eachDefaultSystem (system:
        let
            pkgs = import nixpkgs {
                inherit system;
                config.allowUnfree = true;
            };
        in
            {
            packages.nixosConfigurations = {
                nix-rpi-chiron = nixpkgs.lib.nixosSystem {
                    # system = "x86_64-linux";
                    system = "aarch64-linux";
                    # TODO FIX SYSTEM THIS IS THE ISSUE
                    specialArgs = inputs;
                    # yes it is just taking the attribute set capture of everything into this flakes outputs
                    # a module def may look like this the first couple args are handled by the def of nixosSystem
                    # The later are just EVERYTHING GIVEN TO SPECIAL ARGS
                    # helo
                    modules = [
                        ./rpi-base.nix
                        ./klipper.nix
                    ];
                };
            };
            }
    );

}
