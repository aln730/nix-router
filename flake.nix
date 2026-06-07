{
  description = "quartz";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.quartz = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
	./hardware-configuration.nix
        ./modules/networking.nix
        ./modules/dhcp.nix
        ./modules/dns.nix
      ];
    };
  };
}
