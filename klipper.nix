{ system, pkgs, ... }:
let
    system = pkgs.system;
in
{

    # imports = [];
    # options = {};
    # for later
    # options = {
    #     serial
    #     avrConfigFilePath
    #     settingsFilePath
    # };

    config = {

        # environment.systemPackages =  with pkgs; [
        #     system.octoprint
        #     system.klipper
        #     system.klipper-firmware
        #     system.klipper-flash
        # ];

        environment.systemPackages =  with pkgs; [
            octoprint
            klipper
            klipper-firmware
            klipper-flash
        ];

        services.octoprint = {
            enable = true;
            plugins = plugins: [ plugins.octoklipper ];
        };

        # camera streaming setup
        systemd.services.ustreamer = {
            wantedBy = [ "multi-user.target" ];
            description = "uStreamer for video0";
            serviceConfig = {
            Type = "simple";
            ExecStart = ''${pkgs.ustreamer}/bin/ustreamer --encoder=HW --persistent --drop-same-frames=30'';
            };
        };

        # Klipper setup
        services.klipper = {
            user = "root";
            group = "root";
            enable = true;
            # firmwares = {
            #     mcu = {
            #         enable = true;
            #         # Run klipper-genconf to generate this
            #         configFile = ./avr.cfg;
            #         # Serial port connected to the microcontroller
            #         serial = null;
            #         # serial = "/dev/serial/by-id/usb-Silicon_Labs_CP2102_USB_to_UART_Bridge_Controller_0001-if00-port0";
            #         # description = lib.mdDoc "Path to serial port this printer is connected to. Leave `null` to derive it from `service.klipper.settings`.";
            #     };
            # };

            # should move this to its own nix option as a path so it can be reused
            settings = {
                mcu.serial = "/dev/serial/by-id/usb-Silicon_Labs_CP2102_USB_to_UART_Bridge_Controller_0001-if00-port0";

                stepper_x = {
                    step_pin = "PF0";
                    dir_pin = "!PF1";
                    enable_pin = "!PD7";
                    microsteps = 16;
                    rotation_distance = 40;
                    endstop_pin = "^!PE5";
                    position_min = -14;
                    position_endstop = -14;
                    position_max = 400;
                    homing_speed = 100;
                };

                stepper_y = {
                    step_pin = "PF6";
                    dir_pin = "!PF7";
                    enable_pin = "!PF2";
                    microsteps = 16;
                    rotation_distance = 32;
                    endstop_pin = "^!PL7";
                    position_endstop = 0;
                    position_max = 400;
                    homing_speed = 80.0;
                };

                stepper_z = {
                    step_pin = "PL3";
                    dir_pin = "!PL1";
                    enable_pin = "!PK0";
                    microsteps = 16;
                    rotation_distance = 8;
                    endstop_pin = "^PD3";
                    position_max = 450;
                    homing_speed = 5.0;
                };

                stepper_zi = {
                    step_pin = "PC1";
                    dir_pin = "!PC3";
                    enable_pin = "!PC7";
                    microsteps = 16;
                    rotation_distance = 8;
                    endstop_pin = "^PL6";
                };

                # Configured for a 0.6mm nozzle
                extruder = {
                    step_pin = "PA4";
                    dir_pin = "PA6";
                    enable_pin = "!PA2";
                    microsteps = 16;
                    rotation_distance = 7.71; # You might want to put this at 8, I am not sure. in some configs this is an interger, in other configs it is some super specific number;
                    nozzle_diameter = 0.600;
                    filament_diameter = 1.750;
                    heater_pin = "PB4";
                    sensor_type = "ATC Semitec 104GT-2";
                    sensor_pin = "PK5";
                    control = "pid";
                    pid_Kp = 13.664;
                    pid_Ki = 0.352;
                    pid_Kd = 132.707;
                    min_temp = 0;
                    max_temp = 245;
                };

                "heater_fan extruder_fan".pin = "PL5"; # The fan that keeps the extruder itself from overheating, not the fan that blows on the print


                # These PID values are straight from the anycubic I3 config, which is much smaller, seems to work fine but tuning it might be a good idea
                heater_bed = {
                    heater_pin = "PL4";
                    sensor_type = "EPCOS 100K B57560G104F";
                    sensor_pin = "PK6";
                    control = "pid";
                    pid_Kp = 62.207;
                    pid_Ki = 1.325;
                    pid_Kd = 730.153;
                    min_temp = 0;
                    max_temp = 110;
                };

                fan.pin = "PH6"; # The fan that blows on the 3d printed object


                printer = {
                    kinematics = "cartesian";
                    max_velocity = 300;
                    max_accel = 3000;
                    max_z_velocity = 10;
                    max_z_accel = 60;
                };

                "heater_fan stepstick_fan".pin = "PH4"; # the fan inside the controller box that keeps the stepper drivers cool

                "filament_switch_sensor filament_sensor" = {
                    switch_pin = "^!PC4";
                    pause_on_runout = true;
                };

            }; # settings end
        }; # klipper end
    };
}