{
  description = "FoxOS Themeworld - Streamlined Boot Theming System";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    
    # Upstream theme sources
    plymouth-themes = { url = "github:adi1090x/plymouth-themes"; flake = false; };
    dedsec-grub = { url = "github:VandalByte/dedsec-grub2-theme"; flake = false; };
    catppuccin-grub = { url = "github:catppuccin/grub"; flake = false; };
    nixos-boot = { url = "github:Melkor333/nixos-boot"; flake = false; };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Asset helper functions
        assetHelpers = import ./lib/asset-helpers.nix { inherit lib pkgs; };
        lib = nixpkgs.lib;
        
      in {
        # ═══════════════════════════════════════════════════════════════
        # THEME PACKAGES
        # ═══════════════════════════════════════════════════════════════
        packages = {
          # Plymouth themes
          plymouth-foxos-themes = pkgs.stdenv.mkDerivation {
            name = "plymouth-foxos-themes";
            src = ./assets/plymouth;
            
            installPhase = ''
              mkdir -p $out/share/plymouth/themes
              
              # Install custom themes
              for theme in evil-nix rainbow-nix pride-nix dragon-foxos; do
                if [ -d "$theme" ]; then
                  cp -r "$theme" $out/share/plymouth/themes/
                  chmod -R 644 $out/share/plymouth/themes/$theme/*
                fi
              done
            '';
            
            meta = {
              description = "FoxOS Plymouth theme collection";
              license = lib.licenses.gpl3;
            };
          };
          
          # GRUB themes
          grub-dedsec-themes = pkgs.stdenv.mkDerivation {
            name = "grub-dedsec-themes";
            src = ./assets/grub/dedsec;
            
            installPhase = ''
              mkdir -p $out/share/grub/themes
              
              # Install all resolution variants
              for res in 1080p 1440p; do
                for style in wannacry sitedown hackerden firewall; do
                  if [ -d "deadsec-$res/$style" ]; then
                    cp -r "deadsec-$res/$style" $out/share/grub/themes/dedsec-$style-$res
                  fi
                done
              done
            '';
            
            meta = {
              description = "DedSec GRUB theme collection";
              license = lib.licenses.gpl3;
            };
          };
          
          # Development tools
          themeworld-cli = pkgs.writeShellScriptBin "themeworld" ''
            #!/usr/bin/env bash
            echo "🎨 FoxOS Themeworld CLI"
            echo "Available commands:"
            echo "  list-themes    - Show available themes"
            echo "  validate       - Validate theme structure"
            echo "  switch <theme> - Switch boot theme"
          '';
          
          default = self.packages.${system}.plymouth-foxos-themes;
        };
        
        # ═══════════════════════════════════════════════════════════════
        # DEVELOPMENT SHELL
        # ═══════════════════════════════════════════════════════════════
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            git nixos-rebuild jq tree imagemagick fontconfig
            self.packages.${system}.themeworld-cli
          ];
          
          shellHook = ''
            echo "🦊 FoxOS Themeworld Development"
            echo "Usage: nix run .#themeworld"
          '';
        };
      }
    ) // {
      # ═══════════════════════════════════════════════════════════════
      # NIXOS MODULES
      # ═══════════════════════════════════════════════════════════════
      nixosModules = {
        # Main themeworld module
        default = import ./modules/themeworld.nix { themeInputs = inputs; };
        
        # Individual components
        boot-selection = ./modules/boot-selection.nix;
        theme-coordination = ./modules/theme-coordination.nix;
        
        # Legacy compatibility
        themeworld = self.nixosModules.default;
      };
      
      # ═══════════════════════════════════════════════════════════════
      # THEME PRESETS
      # ═══════════════════════════════════════════════════════════════
      themePresets = {
        grub-dragon = {
          bootloader = "grub";
          plymouth = { theme = "dragon"; };
          grub = { style = "wannacry"; resolution = "1440p"; };
        };
        
        systemd-evil = {
          bootloader = "systemd-boot";
          plymouth = { theme = "evil-nix"; };
          systemd = { style = "sitedown"; resolution = "1440p"; };
        };
        
        refind-cosmic = {
          bootloader = "refind";
          plymouth = { theme = "dragon-foxos"; };
          refind = { theme = "deepseek-cosmic"; };
        };
      };
    };
}
