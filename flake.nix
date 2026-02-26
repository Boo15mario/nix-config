{
  description = "access-OS and personal NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    access-nix = {
      url = "github:boo15mario/access-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, access-nix, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      
      # Helper to create a configuration
      mkHost = hostName: path: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          path
          {
            networking.hostName = hostName;
            nixpkgs.overlays = [ access-nix.overlays.default ];
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        hp-boo = mkHost "hp-boo" ./hp-boo/configuration.nix;
        boo76 = mkHost "boo76" ./boo76/configuration.nix;
        boo15mario = mkHost "boo15mario" ./boo15mario/configuration.nix;
        "boo15mario-main" = mkHost "boo15mario-main" ./boo15mario-main/configuration.nix;
        
        # ISO configuration
        iso = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./custom-iso/configuration.nix
            {
              nixpkgs.overlays = [ access-nix.overlays.default ];
            }
          ];
        };
      };

      # Allow building the ISO image directly
      packages.${system} = {
        iso = self.nixosConfigurations.iso.config.system.build.isoImage;
        default = self.packages.${system}.iso;
      };
    };
}
