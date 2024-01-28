{ config, pkgs, lib, inputs, ... }:
{

    # MOVE INTO ITS OWN FILE FOR HARDWARE
    environment.systemPackages = with pkgs; [
      libraspberrypi
      raspberrypi-eeprom
    ];

    # "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix" creates a
    # disk with this label on first boot. Therefore, we need to keep it. It is the
    # only information from the installer image that we need to keep persistent
    fileSystems."/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };

    boot = {
      kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_rpi4;
      loader = {
        generic-extlinux-compatible.enable = lib.mkDefault true;
        grub.enable = lib.mkDefault false;
      };
    };

    hardware = {
      raspberry-pi."4".fkms-3d.enable = true;
      # audio still not building

      #raspberry-pi."4".apply-overlays-dtmerge.enable = true;
      # raspberry-pi."4".audio.enable = true;
      # pulseaudio.enable = true;
    };
    # sound.enable = true;

    console.enable = false;

    # see these issues for why this is needed
    #https://github.com/NixOS/nixpkgs/issues/154163
    #https://github.com/NixOS/nixpkgs/issues/126755
    # yes this is needed confirmed via ablation testing
    nixpkgs.overlays = [
      (final: prev: {
        makeModulesClosure = x:
          prev.makeModulesClosure (x // { allowMissing = true; });
      })
    ];
}
