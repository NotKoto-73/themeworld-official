# modules/dedsec-unified-theme.nix
{ config, lib, pkgs, ... }:

with lib;

let
  grubCfg = config.boot.loader.grub.dedsec-theme;
  systemdCfg = config.boot.loader.systemd-boot.dedsec-theme;
  
  # GRUB theme derivation with proper SHA256
  dedsec-grub-theme = pkgs.stdenv.mkDerivation {
    name = "dedsec-grub-theme";
    
    src = pkgs.fetchFromGitHub {
      owner = "VandalByte";
      repo = "dedsec-grub2-theme";
      rev = "main";
      sha256 = "sha256-0hz8g17bzg4z154pcwxyrlwbjb0hbqfc0vlqi8ijzs6fj9ckxkj3"; # TODO: Replace with actual hash
      # Run: nix-prefetch-url --unpack https://github.com/VandalByte/dedsec-grub2-theme/archive/main.tar.gz
    };
    
    installPhase = ''
      mkdir -p $out/grub/themes/dedsec
      
      # Check if required directories exist
      if [ ! -d "assets/backgrounds" ]; then
        echo "Error: assets/backgrounds directory not found in source"
        ls -la
        exit 1
      fi
      
      # Copy the specific variant files based on options
      cp "assets/backgrounds/${grubCfg.style}-${grubCfg.resolution}.png" $out/grub/themes/dedsec/background.png
      
      # Copy icons (check if directory exists first)
      if [ -d "assets/icons-${grubCfg.resolution}/${grubCfg.icon}" ]; then
        cp -r "assets/icons-${grubCfg.resolution}/${grubCfg.icon}/"* $out/grub/themes/dedsec/
      fi
      
      # Copy fonts  
      if [ -d "assets/fonts/${grubCfg.resolution}" ]; then
        cp -r "assets/fonts/${grubCfg.resolution}/"* $out/grub/themes/dedsec/
      fi
      
      # Copy base theme files
      if [ -d "base/${grubCfg.resolution}" ]; then
        cp -r "base/${grubCfg.resolution}/"* $out/grub/themes/dedsec/
      fi
      
      # Make sure theme.txt exists and is properly configured
      if [ -f "$out/grub/themes/dedsec/theme.txt" ]; then
        # Update background path in theme.txt if needed
        sed -i 's|desktop-image:.*|desktop-image: "background.png"|' "$out/grub/themes/dedsec/theme.txt"
      else
        # Create a basic theme.txt if it doesn't exist
        cat > "$out/grub/themes/dedsec/theme.txt" << EOF
      +-------------------------------------------------+
      | DedSec GRUB Theme                               |
      | Background: ${grubCfg.style}-${grubCfg.resolution}            |
      | Icons: ${grubCfg.icon}                          |
      +-------------------------------------------------+
      EOF
      fi
    '';
    
    meta = with lib; {
      description = "DedSec GRUB2 theme";
      homepage = "https://github.com/VandalByte/dedsec-grub2-theme";
      license = licenses.gpl3;
      platforms = platforms.linux;
    };
  };
  
  # systemd-boot configuration - more realistic approach
  dedsec-systemd-config = pkgs.writeText "loader.conf" ''
    timeout ${toString systemdCfg.timeout}
    console-mode max
    editor ${if systemdCfg.showEditor then "yes" else "no"}
    
    # DedSec Boot Loader
    # Style: ${systemdCfg.style}
  '';
  
in
{
  # ────────────────── GRUB DEDSEC OPTIONS ──────────────────
  options.boot.loader.grub.dedsec-theme = {
    enable = mkEnableOption "DedSec GRUB theme";
    
    style = mkOption {
      type = types.enum [
        "brainwash" "compact" "comments" "firewall" "fuckery" 
        "hackerden" "legion" "lovetrap" "mashup" "reaper"
        "redskull" "stalker" "spam" "spyware" "strike"
        "sitedown" "trolls" "tremor" "unite" "wannacry" "wrench"
      ];
      default = "wannacry";
      description = "DedSec theme variant to use";
    };
    
    icon = mkOption {
      type = types.enum [ "color" "white" ];
      default = "color";
      description = "Icon style to use";
    };
    
    resolution = mkOption {
      type = types.enum [ "1080p" "1440p" ];
      default = "1440p";
      description = "Screen resolution";
    };
  };
  
  # ────────────────── SYSTEMD-BOOT DEDSEC OPTIONS ──────────────────
  options.boot.loader.systemd-boot.dedsec-theme = {
    enable = mkEnableOption "DedSec-style systemd-boot theme";
    
    style = mkOption {
      type = types.enum [ "wannacry" "sitedown" "hacker" "minimal" ];
      default = "wannacry";
      description = "DedSec style variant (mainly affects boot entry naming)";
    };
    
    timeout = mkOption {
      type = types.int;
      default = 5;
      description = "Boot timeout in seconds";
    };
    
    showEditor = mkOption {
      type = types.bool;
      default = true;
      description = "Allow kernel parameter editing";
    };
  };
  
  # ────────────────── CONFIGURATION ──────────────────
  config = mkMerge [
    # GRUB DedSec theme
    (mkIf (grubCfg.enable && config.boot.loader.grub.enable) {
      boot.loader.grub.theme = "${dedsec-grub-theme}/grub/themes/dedsec";
    })
    
    # systemd-boot DedSec styling
    (mkIf (systemdCfg.enable && config.boot.loader.systemd-boot.enable) {
      boot.loader.systemd-boot = {
        consoleMode = "max";
        editor = systemdCfg.showEditor;
        configurationLimit = 10;
      };
      
      # More realistic systemd-boot theming approach
      systemd.services.systemd-boot-update-service = mkIf config.boot.loader.systemd-boot.enable {
        serviceConfig.ExecStartPre = [
          "+${pkgs.writeShellScript "dedsec-systemd-boot-setup" ''
            # Copy our custom loader.conf
            if [ -d /boot/loader ]; then
              cp ${dedsec-systemd-config} /boot/loader/loader.conf
              echo "DedSec systemd-boot theme applied: ${systemdCfg.style}"
            fi
          ''}"
        ];
      };
    })
  ];
}
