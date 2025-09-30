# modules/nixos/personalization/theme-multiverse.nix
{ config, lib, pkgs, ... }:

let
  inherit (lib) mkOption mkEnableOption types;
  cfg = config.foxos.themeMultiverse;

  # Theme categorization and intelligence
  themeCategories = {
    # Cyberpunk/Hacker Aesthetic
    cyberpunk = [
      "dedsec-wannacry" "dedsec-sitedown" "dedsec-hackerden" 
      "dedsec-firewall" "matrix-mode" "glitch-dimension"
    ];
    
    # AI/Future Tech
    aiTech = [
      "deepseek-cosmic" "deepseek-legendary" "claude-purple"
      "gemini-refined" "gpt-assistant"
    ];
    
    # Mystical/Space
    mystical = [
      "foxos-astrology" "cosmic-nebula" "stellar-navigation"
      "nyan-rainbow" "unicorn-dreams"
    ];
    
    # Classic/Elegant  
    classic = [
      "catppuccin-mocha" "catppuccin-frappe" "nord-aurora"
      "gruvbox-dark" "solarized-refined"
    ];
    
    # Gaming/Pop Culture
    gaming = [
      "portal-aperture" "undertale-determination" "doom-eternal"
      "konami-classic" "retro-arcade"
    ];
  };

  # Loader type detection and capabilities
  loaderCapabilities = {
    "grub" = {
      supportsCustomThemes = true;
      supportsAnimations = true;
      supportsCustomFonts = true;
      supportsCustomResolutions = true;
      configFile = "grub.cfg";
      themePath = "/boot/grub/themes";
    };
    
    "systemd-boot" = {
      supportsCustomThemes = false;
      supportsAnimations = false;
      supportsCustomFonts = false;
      supportsCustomResolutions = false;
      configFile = "loader.conf";
      themePath = null;
    };
    
    "refind" = {
      supportsCustomThemes = true;
      supportsAnimations = true;
      supportsCustomFonts = true;
      supportsCustomResolutions = true;
      configFile = "refind.conf";
      themePath = "/boot/EFI/refind/themes";
    };
    
    "plymouth" = {
      supportsCustomThemes = true;
      supportsAnimations = true;
      supportsCustomFonts = true;
      supportsCustomResolutions = true;
      configFile = "plymouthd.conf";
      themePath = "/usr/share/plymouth/themes";
    };
  };

  # Smart theme compatibility matrix
  themeCompatibility = theme: loader: 
    let 
      caps = loaderCapabilities.${loader} or {};
      themeRequirements = themeRequirements.${theme} or {};
    in
    caps.supportsCustomThemes && 
    (themeRequirements.needsAnimations -> caps.supportsAnimations) &&
    (themeRequirements.needsCustomFonts -> caps.supportsCustomFonts);

  # Theme requirements database
  themeRequirements = {
    "dedsec-wannacry" = { needsAnimations = true; needsCustomFonts = true; complexity = "high"; };
    "deepseek-cosmic" = { needsAnimations = true; needsCustomFonts = false; complexity = "medium"; };
    "claude-purple" = { needsAnimations = false; needsCustomFonts = true; complexity = "low"; };
    "systemd-minimal" = { needsAnimations = false; needsCustomFonts = false; complexity = "minimal"; };
  };

  # Available theme packages (from your themeworld structure)
  availableThemes = {
    # DedSec collection
    "dedsec-wannacry" = {
      grub = "${pkgs.grub-dedsec-themes}/dedsec-wannacry-1440p";
      plymouth = "${pkgs.plymouth-foxos-themes}/dragon-foxos";
      refind = null; # Not available
    };
    
    "dedsec-sitedown" = {
      grub = "${pkgs.grub-dedsec-themes}/dedsec-sitedown-1440p";
      plymouth = "${pkgs.plymouth-foxos-themes}/evil-nix";
      refind = null;
    };
    
    # AI Assistant themes
    "deepseek-cosmic" = {
      grub = null;
      plymouth = "${pkgs.plymouth-foxos-themes}/rainbow-nix";
      refind = pkgs.callPackage ./themes/refind/deepseek/cosmic.nix {};
    };
    
    "deepseek-legendary" = {
      grub = null;
      plymouth = "${pkgs.plymouth-foxos-themes}/dragon-foxos";
      refind = pkgs.callPackage ./themes/refind/deepseek/legendary.nix {};
    };
    
    "claude-purple" = {
      grub = null;
      plymouth = "${pkgs.plymouth-foxos-themes}/pride-nix";
      refind = pkgs.callPackage ./themes/refind/claude/claude.nix {};
    };
    
    "gemini-refined" = {
      grub = null;
      plymouth = "${pkgs.plymouth-foxos-themes}/rainbow-nix";
      refind = pkgs.callPackage ./themes/refind/gemini/gemini.nix {};
    };
    
    # Classic themes
    "catppuccin-mocha" = {
      grub = "${pkgs.catppuccin-grub}/catppuccin-mocha";
      plymouth = "${pkgs.plymouth-foxos-themes}/evil-nix";
      refind = pkgs.callPackage ./themes/refind/classic/catppuccin.nix {};
    };
  };

  # Generate coordinated theme configuration
  generateThemeConfig = selectedTheme: selectedLoader: 
    let 
      theme = availableThemes.${selectedTheme} or {};
      loaderTheme = theme.${selectedLoader} or null;
      plymouthTheme = theme.plymouth or null;
    in {
      loader = if loaderTheme != null then {
        ${selectedLoader} = {
          theme = loaderTheme;
          enable = true;
        };
      } else {};
      
      plymouth = if plymouthTheme != null then {
        enable = true;
        theme = builtins.baseNameOf plymouthTheme;
        themePackages = [ plymouthTheme ];
      } else {};
    };

in {
  # ═══════════════════════════════════════════════════════════════
  # OPTIONS DEFINITION
  # ═══════════════════════════════════════════════════════════════
  
  options.foxos.themeMultiverse = {
    enable = mkEnableOption "FoxOS Theme & Loader Multiverse System";
    
    # Theme selection
    selectedTheme = mkOption {
      type = types.enum (builtins.attrNames availableThemes);
      default = "deepseek-cosmic";
      description = ''
        Active theme across all boot components.
        
        Available themes by category:
        • Cyberpunk: ${toString themeCategories.cyberpunk}
        • AI/Tech: ${toString themeCategories.aiTech}  
        • Mystical: ${toString themeCategories.mystical}
        • Classic: ${toString themeCategories.classic}
        • Gaming: ${toString themeCategories.gaming}
      '';
    };
    
    # Loader selection
    selectedLoader = mkOption {
      type = types.enum [ "grub" "systemd-boot" "refind" ];
      default = "grub";
      description = "Primary bootloader to theme";
    };
    
    # Advanced options
    enablePlymouthIntegration = mkOption {
      type = types.bool;
      default = true;
      description = "Coordinate Plymouth splash screens with bootloader themes";
    };
    
    enableAnimations = mkOption {
      type = types.bool;
      default = true;
      description = "Enable theme animations where supported";
    };
    
    enableEasterEggs = mkOption {
      type = types.bool;
      default = false;
      description = "Enable easter eggs in supported themes";
    };
    
    chaosLevel = mkOption {
      type = types.enum [ "normal" "chaos" "insanity" ];
      default = "normal";
      description = "Chaos level for interactive themes (DeepSeek Legendary)";
    };
    
    # Theme variant options
    themeVariant = mkOption {
      type = types.str;
      default = "standard";
      description = "Theme variant (e.g., dark-moon, full-moon, cosmic)";
    };
    
    # Resolution and display
    resolution = mkOption {
      type = types.str;
      default = "1440p";
      description = "Target display resolution for themes";
    };
    
    timeout = mkOption {
      type = types.int;
      default = 10;
      description = "Boot menu timeout in seconds";
    };
  };
  
  # ═══════════════════════════════════════════════════════════════
  # CONFIGURATION LOGIC
  # ═══════════════════════════════════════════════════════════════
  
  config = lib.mkIf cfg.enable {
    
    # Validate theme/loader compatibility
    assertions = [
      {
        assertion = themeCompatibility cfg.selectedTheme cfg.selectedLoader;
        message = "Theme '${cfg.selectedTheme}' is not compatible with loader '${cfg.selectedLoader}'";
      }
    ];
    
    # Generate coordinated theme configuration
    boot = lib.mkMerge [
      # GRUB configuration
      (lib.mkIf (cfg.selectedLoader == "grub") {
        loader.grub = {
          enable = true;
          efiSupport = true;
          device = "nodev";
          theme = availableThemes.${cfg.selectedTheme}.grub or null;
          timeout = cfg.timeout;
          gfxmodeEfi = if cfg.resolution == "1440p" then "1440x900" else "1920x1080";
        };
        loader.systemd-boot.enable = false;
      })
      
      # systemd-boot configuration  
      (lib.mkIf (cfg.selectedLoader == "systemd-boot") {
        loader.systemd-boot = {
          enable = true;
          timeout = cfg.timeout;
          editor = true;
          configurationLimit = 20;
        };
        loader.grub.enable = false;
      })
      
      # rEFInd configuration
      (lib.mkIf (cfg.selectedLoader == "refind") {
        loader.refind = {
          enable = true;
          theme = availableThemes.${cfg.selectedTheme}.refind or null;
          timeout = cfg.timeout;
        };
        loader.grub.enable = false;
        loader.systemd-boot.enable = false;
      })
      
      # Plymouth integration
      (lib.mkIf cfg.enablePlymouthIntegration {
        plymouth = {
          enable = true;
          theme = 
            let plymouthTheme = availableThemes.${cfg.selectedTheme}.plymouth or null;
            in if plymouthTheme != null 
               then builtins.baseNameOf plymouthTheme
               else "spinner";
        };
      })
    ];
    
    # Install theme packages
    environment.systemPackages = with pkgs; [
      # Core theme collections
      grub-dedsec-themes
      plymouth-foxos-themes
      catppuccin-grub
      
      # Theme management tools
      (writeShellScriptBin "foxos-theme" ''
        #!/usr/bin/env bash
        
        case "$1" in
          list)
            echo "Available themes:"
            ${lib.concatMapStringsSep "\n" (theme: 
              "echo '  ${theme} (${lib.concatStringsSep ", " (lib.attrNames (availableThemes.${theme} or {}))})'") 
              (builtins.attrNames availableThemes)}
            ;;
          switch)
            echo "Switching to theme: $2"
            echo "This requires a system rebuild to take effect."
            ;;
          preview)
            echo "Theme preview for: $2"
            # Could show ASCII art preview or open theme screenshots
            ;;
          *)
            echo "Usage: foxos-theme {list|switch|preview} [theme-name]"
            ;;
        esac
      '')
    ];
    
    # Theme-specific configurations
    imports = [
      # Import theme-specific modules based on selection
    ] ++ lib.optional (cfg.selectedTheme == "deepseek-legendary") 
          ./themes/refind/deepseek/legendary.nix
      ++ lib.optional (cfg.selectedTheme == "claude-purple")
          ./themes/refind/claude/claude.nix
      ++ lib.optional (builtins.hasPrefix "dedsec-" cfg.selectedTheme)
          ./themes/grub/dedsec.nix;
    
    # Pass configuration to theme modules
    foxos.desktop.theming.bootloader = lib.mkIf (cfg.selectedLoader == "refind") {
      timeout = cfg.timeout;
      resolution = if cfg.resolution == "1440p" then "2560x1440" else "1920x1080";
      
      # DeepSeek Legendary specific options
      ai.deepseek.legendary = lib.mkIf (cfg.selectedTheme == "deepseek-legendary") {
        enable = true;
        enableEasterEggs = cfg.enableEasterEggs;
        chaosLevel = cfg.chaosLevel;
      };
      
      # Claude theme specific options  
      custom.claude = lib.mkIf (cfg.selectedTheme == "claude-purple") {
        enable = true;
        variant = cfg.themeVariant;
      };
    };
    
    # System activation scripts for theme coordination
    system.activationScripts.themeMultiverse = ''
      echo "🎨 Activating FoxOS Theme Multiverse: ${cfg.selectedTheme} on ${cfg.selectedLoader}"
      
      # Ensure theme directories exist
      mkdir -p /boot/grub/themes 2>/dev/null || true
      mkdir -p /boot/EFI/refind/themes 2>/dev/null || true
      
      # Log active theme configuration
      echo "Theme: ${cfg.selectedTheme}" > /etc/foxos-active-theme
      echo "Loader: ${cfg.selectedLoader}" >> /etc/foxos-active-theme
      echo "Chaos Level: ${cfg.chaosLevel}" >> /etc/foxos-active-theme
      echo "Easter Eggs: ${toString cfg.enableEasterEggs}" >> /etc/foxos-active-theme
    '';
  };
}