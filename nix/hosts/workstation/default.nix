{ pkgs, ... }:

let
  hostName = "evolve-nixos-workstation";
  sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAZLVfPatp7YOYiWAmpDMibN9CNLCmqEOhWZ8bsqvENa gibbz@evolve-leissner";
in
{
  imports = [
    ./hardware.nix
    ../../applications/podman.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # SSH
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [ sshKey ];

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
    packages = with pkgs; [
      git
    ];
  };

  # TODO: to separate file?
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    tree
  ];

  system.stateVersion = "24.05";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
