{ config, pkgs, ... }:
let
  #unstable = import (import ./nixpkgs-src.nix).stable { config = {allowUnfree = true; }; };
  #my_steam = (pkgs.steam.override { nativeOnly = true; });
  #my_steam = unstable.steam;
  #steam_autostart = (pkgs.makeAutostartItem { name = "steam"; package = pkgs.steam; });
in
{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "telku"; # Define your hostname.
  networking.networkmanager.enable = true;

  # open ports for steam stream and some games
  networking.firewall.allowedTCPPorts = with pkgs.lib; [ 27036 27037 ] ++ (range 27015 27030);
  networking.firewall.allowedUDPPorts = with pkgs.lib; [ 4380 27036 ] ++ (range 27000 27031);
  networking.firewall.allowPing = true;
  
  nixpkgs.config.kodi.enableAdvancedLauncher = true;
  environment.systemPackages = with pkgs; [
    wget vim htop
    # GAMING
    steam
    #steam_autostart
    steam-run
    wmctrl
    xdotool
  ];

  # enable ssh
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    #settings.PermitRootLogin = "yes";
  };

  # Xbox controller
  boot.extraModprobeConfig = '' options bluetooth disable_ertm=1 '';

  # Gaming 32bit
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  hardware.pulseaudio.support32Bit = true;

  hardware.steam-hardware.enable = true;
  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluezFull;
  };
  

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";
  services.xserver.videoDrivers = [ "nvidia" ];

  # Enable the KDE Desktop Environment.
  #services.xserver.displayManager.sddm = {
  #  enable = true;
  #  autoLogin = {
  #    enable = true;
  #    user = "telku";
  #  };
  #};
  #services.xserver.desktopManager.plasma5.enable = true;
  services.xserver = {
    displayManager.lightdm.enable = true;
    displayManager.autoLogin = {
      enable = true;
      user = "telku";
    };
    displayManager.defaultSession = "none+openbox";
    windowManager.openbox.enable = true;
  };

  nixpkgs.overlays = [
    (self: super: {
    })
  ];

  systemd.user.services.kodi = {
    description = "Kodi as systemd service";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];

    serviceConfig =
      let
        package = pkgs.kodi.withPackages (p: with p; [
          a4ksubtitles
          #jellyfin
          keymap
          pvr-iptvsimple
          vfs-libarchive
          vfs-sftp

          iagl
          steam-library
          steam-launcher
          joystick
          libretro-genplus
          libretro-mgba
          libretro-snes9x
        ]);
      in
      {
        ExecStart = "${package}/bin/kodi";
        Restart = "on-failure";
      };
  };

  nixpkgs.config.customServices.steamcontroller.enable = true;

  # Users
  users = {
    mutableUsers = false;
    users = {
      telku = {
        password = "telku";
        isNormalUser = true;
        extraGroups = [ "wheel" "dialout" ];
      };
    };
  };

  services.udev.extraRules = ''
      # Sony PlayStation DualShock 4; bluetooth; USB
      KERNEL=="hidraw*", KERNELS=="*054C:05C4*", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="05c4", MODE="0660", TAG+="uaccess"
      # Sony PlayStation DualShock 4 Slim; bluetooth; USB
      KERNEL=="hidraw*", KERNELS=="*054C:09CC*", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="09cc", MODE="0660", TAG+="uaccess"
      # Sony PlayStation DualShock 4 Wireless Adapter; USB
      KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ba0", MODE="0660", TAG+="uaccess"
  '';

  # In case nix builds are executed from that machine.
  nix.maxJobs = 20;

  # timezone
  time.timeZone = "Europe/Tallinn";

  systemd.extraConfig = "DefaultLimitNOFILE=1048576";
  boot.kernelPackages = pkgs.linuxPackages_latest;
}

