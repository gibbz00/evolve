{ pkgs, ... }:

let hostName = "evolve-nixos-edge"; in
{
  # TODO: parameterize
  imports = [
    ./hardware.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # SSH
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    # TODO: parameterize
    "CHANGE_ME"
  ];

  # TODO: parameterize
  networking = {
    inherit hostName;
    networkmanager.enable = true;
  };

  # TODO: parameterize
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.

  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # TODO: to separate file?
  users.users.gibbz = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    # Generated with `mkpasswd`
    hashedPassword = "$y$j9T$xKGza1jEG4B/sjLUrd8NI/$mDS1esp/CbAJrVnDe4fD0ngC2wB0BPRF13Tsu3qjMP7"
    # TODO: users sets up his own
    packages = with pkgs; [];
  };

  # TODO: to separate file
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
  ];


  system.stateVersion = "unstable";
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;
  system.autoUpgrade.channel = "https://channels.nixos.org/nixos-unstable";

  # TODO: either move to home, remove or parameterize
  networking.wireless = {
    enable = true;
    userControlled.enable = true;
  };
  # TODO: move to home?
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };
}
