{ pkgs, ... }:

{
  # TODO: parameterize
  imports = [ ./hardware/workstation/hardware-configuration.nix ];

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
  networking.hostName = "evolve-nixos-workstation";
  networking.networkmanager.enable = true;

  # TODO: parameterize
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure keymap in X11
  # TODO: move to home?
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # TODO: to separate file
  users.users.gibbz = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    # TODO: users sets up his own
    packages = with pkgs; [];
  };

  # TODO: to separate file
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
  ];


  # TODO: to separate file?
  system.stateVersion = "unstable";
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;
  system.autoUpgrade.channel = "https://channels.nixos.org/nixos-unstable";

  # TODO: either move to home, remove or parameterize
  #   networking.wireless = {
  #     enable = true;
  #     userControlled.enable = true;
  #   };
  # TODO: move to home?
  # i18n.extraLocaleSettings = {
  #   LC_ADDRESS = "sv_SE.UTF-8";
  #   LC_IDENTIFICATION = "sv_SE.UTF-8";
  #   LC_MEASUREMENT = "sv_SE.UTF-8";
  #   LC_MONETARY = "sv_SE.UTF-8";
  #   LC_NAME = "sv_SE.UTF-8";
  #   LC_NUMERIC = "sv_SE.UTF-8";
  #   LC_PAPER = "sv_SE.UTF-8";
  #   LC_TELEPHONE = "sv_SE.UTF-8";
  #   LC_TIME = "sv_SE.UTF-8";
  # };
}
