{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, disko, ... }:
    {
      colmena = {
        meta = {
          nixpkgs = import nixpkgs {
            system = "x86_64-linux";
          };
        };

        workstation = {
          deployment = {
            targetHost = "evolve-nixos-workstation.lan";
          };
          networking.hostName = "evolve-nixos-workstation";
          imports = [
            ./hosts/workstation/default.nix
            disko.nixosModules.disko
          ];
        };
      };
    };
}
