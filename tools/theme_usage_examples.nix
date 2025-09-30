# Example configurations for FoxOS Theme & Loader Multiverse

# ================================================================================================
# EXAMPLE 1: The Cyberpunk Hacker Setup - DedSec WannaCry Theme
# ================================================================================================
{
  imports = [ ./modules/nixos/personalization/theme-multiverse.nix ];
  
  foxos.themeMultiverse = {
    enable = true;
    selectedTheme = "dedsec-wannacry";
    selectedLoader = "grub";
    
    # Full cyberpunk experience
    enablePlymouthIntegration = true;
    enableAnimations = true;
    enableEasterEggs = false; # Keep it professional
    
    resolution = "1440p";
    timeout = 5; # Quick boot for the impatient hacker
  };
  
  # Coordinate with desktop theme
  foxos.themeCoordination = {
    enable = true;
    coordinateDesktopThemes = true;
    coordinateTerminalThemes = true;
  };
  
  # Result:
  # - GRUB with DedSec WannaCry theme (green matrix aesthetic)
  # - Plymouth dragon splash screen
  # - Terminal with matching green/black color scheme
  # - Desktop themes coordinate with cyberpunk aesthetic
}

# ================================================================================================
# EXAMPLE 2: The AI Researcher Setup - DeepSeek Legendary Maximum Chaos
# ================================================================================================
{
  imports = [ ./modules/nixos/personalization/theme-multiverse.nix ];
  
  foxos.themeMultiverse = {
    enable = true;
    selectedTheme = "deepseek-legendary";
    selectedLoader = "refind";
    
    # Maximum chaos and interactivity
    enablePlymouthIntegration = true;
    enableAnimations = true;
    enableEasterEggs = true;
    chaosLevel = "insanity";
    
    resolution = "1440p";
    timeout = 15; # More time to appreciate the easter eggs
  };
  
  # Result:
  # - rEFInd with DeepSeek Legendary theme
  # - 40+ easter eggs including DOOM, BSOD simulator, Konami code
  # - Puzzle challenges with SHA256 hashes
  # - TempleOS homage, Portal Gun, Undertale references
  # - Plymouth dragon splash with cosmic effects
}

# ================================================================================================
# EXAMPLE 3: The Minimalist Professional - Claude Purple Elegance
# ================================================================================================
{
  imports = [ ./modules/nixos/personalization/theme-multiverse.nix ];
  
  foxos.themeMultiverse = {
    enable = true;
    selectedTheme = "claude-purple";
    selectedLoader = "refind";
    
    # Clean, professional aesthetic
    enablePlymouthIntegration = true;
    enableAnimations = false; # Subtle and refined
    enableEasterEggs = false;
    chaosLevel = "normal";
    
    themeVariant = "standard";
    resolution = "1440p";
    timeout = 7;
  };
  
  foxos.themeCoordination = {
    enable = true;
    coordinateDesktopThemes = true;
    coordinateTerminalThemes = true;
    coordinateBrowserThemes = true; # Professional consistency
  };
  
  # Result:
  # - rEFInd with elegant purple gradient theme
  # - Clean, sophisticated visual design
  # - Coordinated purple color scheme across system
  # - Professional aesthetic suitable for work environments
}

# ================================================================================================
# EXAMPLE 4: The Retro Gaming Enthusiast - Nyan Cat Rainbow Mode
# ================================================================================================
{
  imports = [ ./modules/nixos/personalization/theme-multiverse.nix ];
  
  foxos.themeMultiverse = {
    enable = true;
    selectedTheme = "nyan-rainbow";
    selectedLoader = "refind";
    
    # Maximum fun and nostalgia
    enablePlymouthIntegration = true;
    enableAnimations = true;
    enableEasterEggs = true;
    chaosLevel = "chaos"; # Some fun, not complete insanity
    
    resolution = "1080p"; # Retro resolution
    timeout = 10;
  };
  
  # Result:
  # - rEFInd with rainbow Nyan Cat theme
  # - Plymouth rainbow splash screen
  # - Gaming easter eggs and retro references
  # - Nostalgic 8-bit aesthetic throughout
}

# ================================================================================================
# EXAMPLE 5: Multi-Boot Gaming Rig - Theme Switching Based on OS Selection
# ================================================================================================
{
  imports = [ ./modules/nixos/personalization/theme-multiverse.nix ];
  
  foxos.themeMultiverse = {
    enable = true;
    selectedTheme = "gemini-refined";
    selectedLoader = "refind";
    
    # Balanced for multi-OS setup
    enablePlymouthIntegration = true;
    enableAnimations = true;
    enableEasterEggs = false;
    
    resolution = "1440p";
    timeout = 20; # More time to choose OS
  };
  
  # Custom rEFInd configuration for multi-boot
  boot.loader.refind.extraConfig = ''
    # Different themes/icons for different operating systems
    menuentry "FoxOS (NixOS)" {
      icon EFI/refind/themes/gemini-refined/icons/os_foxos.png
      loader /EFI/nixos/grubx64.efi
    }
    
    menuentry "Arch Linux (Gaming)" {
      icon EFI/refind/themes/gemini-refined/icons/os_arch.png
      loader /EFI/arch/grubx64.efi
      volume "ARCH_ESP"
    }
    
    menuentry "Windows 11 (Compatibility)" {
      icon EFI/refind/themes/gemini-refined/icons/os_win.png
      loader /EFI/Microsoft/Boot/bootmgfw.efi
      volume "ESP_WIN"
    }
  '';
  
  # Result:
  # - Beautiful rEFInd theme with cosmic blue/purple gradient
  # - Custom icons for each operating system
  # - Proper multi-boot management with visual flair
  # - Plymouth coordination for NixOS boots
}

# ================================================================================================
# EXAMPLE 6: Development Environment - Theme Hot-Swapping System
# ================================================================================================
{
  imports = [ ./modules/nixos/personalization/theme-multiverse.nix ];
  
  foxos.themeMultiverse = {
    enable = true;
    selectedTheme = "deepseek-cosmic";
    selectedLoader = "grub";
    
    enablePlymouthIntegration = true;
    enableAnimations = true;
    enableEasterEggs = true;
    chaosLevel = "normal";
    
    resolution = "1440p";
    timeout = 8;
  };
  
  # Development tools for theme management
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "theme-switch" ''
      #!/usr/bin/env bash
      set -euo pipefail
      
      THEME="$1"
      
      echo "Switching FoxOS to theme: $THEME"
      
      # Update configuration
      sudo sed -i "s/selectedTheme = \".*\";/selectedTheme = \"$THEME\";/" /etc/nixos/configuration.nix
      
      # Rebuild system
      echo "Rebuilding system with new theme..."
      sudo nixos-rebuild switch
      
      echo "Theme switch complete! Reboot to see changes."
    '')
    
    (writeShellScriptBin "theme-preview" ''
      #!/usr/bin/env bash
      THEME="$1"
      
      echo "Theme Preview: $THEME"
      echo "==============================================="
      
      case "$THEME" in
        dedsec-*)
          echo "🟢 Cyberpunk hacker aesthetic"
          echo "🟢 Green matrix colors"
          echo "🟢 GRUB recommended"
          ;;
        deepseek-*)
          echo "🔵 AI/cosmic aesthetic"
          echo "🔵 Blue/purple colors"
          echo "🔵 rEFInd recommended"
          ;;
        claude-*)
          echo "🟣 Elegant professional aesthetic"
          echo "🟣 Purple gradient colors"
          echo "🟣 rEFInd recommended"
          ;;
        *)
          echo "ℹ️ Universal theme"
          ;;
      esac
    '')
  ];
  
  # Result:
  # - Easy theme switching with `theme-switch deepseek-legendary`
  # - Theme previews with `theme-preview claude-purple`
  # - Development-friendly workflow for theme experimentation
}

# ================================================================================================
# EXAMPLE 7: Integration with Window Manager Multiverse
# ================================================================================================
{
  imports = [
    ./modules/nixos/personalization/theme-multiverse.nix
    ./modules/nixos/personalization/window-managers.nix
  ];
  
  # Coordinated desktop and boot theming
  foxos.themeMultiverse = {
    enable = true;
    selectedTheme = "catppuccin-mocha";
    selectedLoader = "systemd-boot";
    enablePlymouthIntegration = true;
  };
  
  foxos.windowManagers = {
    managers = [ "hyprland" "gnome" "swayfx" ];
    autoDetectDisplayServer = true;
  };
  
  foxos.themeCoordination = {