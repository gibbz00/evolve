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

        workstation = { name, ... }: {
          deployment = {
            targetHost = "${name}.lan";
          };
          networking.hostName = name;
          imports = [
            ./hosts/${name}/default.nix
            disko.nixosModules.disko
          ];
        };
      };
    };
}
