{ pkgs, ... }:

let hostName = "evolve-nixos-workstation"; in
{
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

  networking = {
    inherit hostName;
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/Stockholm";
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  users.users.gibbz = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    # Generated with `mkpasswd`
    hashedPassword = "$y$j9T$xKGza1jEG4B/sjLUrd8NI/$mDS1esp/CbAJrVnDe4fD0ngC2wB0BPRF13Tsu3qjMP7";
    # TODO: to separate file?
    packages = with pkgs; [];
  };

  # TODO: to separate file?
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    tree
  ];

  system.stateVersion = "24.05";
}
