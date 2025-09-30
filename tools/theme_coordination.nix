# modules/nixos/personalization/theme-coordination.nix
{ config, lib, pkgs, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.foxos.themeCoordination;

  # Theme intelligence and coordination helpers
  themeHelpers = {
    # Analyze theme compatibility across loaders
    analyzeThemeCompatibility = theme: loaders:
      let
        compatibility = builtins.listToAttrs (map (loader: {
          name = loader;
          value = {
            supported = builtins.hasAttr loader (config.foxos.themeMultiverse.availableThemes.${theme} or {});
            quality = 
              if loader == "grub" && builtins.hasPrefix "dedsec-" theme then "excellent"
              else if loader == "refind" && builtins.hasPrefix "deepseek-" theme then "excellent"  
              else if loader == "systemd-boot" then "minimal"
              else "good";
          };
        }) loaders);
      in compatibility;

    # Smart loader recommendation based on theme
    recommendLoader = theme:
      if builtins.hasPrefix "dedsec-" theme then "grub"
      else if builtins.hasPrefix "deepseek-" theme then "refind"
      else if builtins.hasPrefix "claude-" theme then "refind"
      else if theme == "systemd-minimal" then "systemd-boot"
      else "grub"; # Default fallback

    # Generate coordinated color schemes
    extractThemeColors = theme:
      if theme == "dedsec-wannacry" then {
        primary = "#00ff41";
        secondary = "#ff0033";
        background = "#0a0a0a";
        text = "#ffffff";
      }
      else if theme == "deepseek-cosmic" then {
        primary = "#00b4d8";
        secondary = "#4a148c";
        background = "#0a0e17";
        text = "#e2e2e2";
      }
      else if theme == "claude-purple" then {
        primary = "#571b72";
        secondary = "#8247ac";
        background = "#17121a";
        text = "#edecff";
      }
      else {
        primary = "#61affe";
        secondary = "#c06bff";
        background = "#0f052d";
        text = "#ececec";
      };

    # Generate theme-coordinated desktop environment settings
    generateDesktopTheme = theme: {
      gtk = {
        theme = {
          name = if builtins.hasPrefix "dedsec-" theme then "Adwaita-dark"
                 else if builtins.hasPrefix "deepseek-" theme then "Arc-Dark"
                 else "Adwaita";
        };
      };
      
      qt = {
        style = "adwaita-dark";
        platformTheme = "gtk2";
      };
      
      fonts = {
        packages = with pkgs; [
          (if builtins.hasPrefix "dedsec-" theme then fira-code
           else if builtins.hasPrefix "deepseek-" theme then jetbrains-mono
           else inter)
        ];
      };
    };
  };

in {
  options.foxos.themeCoordination = {
    enable = lib.mkEnableOption "Theme coordination across system components";
    
    coordinateDesktopThemes = mkOption {
      type = types.bool;
      default = true;
      description = "Coordinate desktop environment themes with boot themes";
    };
    
    coordinateTerminalThemes = mkOption {
      type = types.bool;
      default = true;
      description = "Coordinate terminal themes with boot themes";
    };
    
    coordinateBrowserThemes = mkOption {
      type = types.bool;
      default = false;
      description = "Coordinate browser themes with boot themes";
    };
  };

  config = lib.mkIf cfg.enable {
    # Desktop theme coordination
    home-manager.users.fox = lib.mkIf cfg.coordinateDesktopThemes (
      themeHelpers.generateDesktopTheme config.foxos.themeMultiverse.selectedTheme
    );
    
    # Terminal theme coordination
    programs.alacritty = lib.mkIf cfg.coordinateTerminalThemes {
      settings = {
        colors = 
          let colors = themeHelpers.extractThemeColors config.foxos.themeMultiverse.selectedTheme;
          in {
            primary = {
              background = colors.background;
              foreground = colors.text;
            };
            normal = {
              black = colors.background;
              red = colors.secondary;
              green = colors.primary;
              yellow = "#fce38a";
              blue = colors.primary;
              magenta = colors.secondary;
              cyan = colors.primary;
              white = colors.text;
            };
          };
      };
    };
    
    # System-wide theme information service
    systemd.services.theme-coordination = {
      description = "FoxOS Theme Coordination Service";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        echo "Theme coordination active"
        echo "Boot theme: ${config.foxos.themeMultiverse.selectedTheme}"
        echo "Loader: ${config.foxos.themeMultiverse.selectedLoader}"
        
        # Export theme info for other services
        mkdir -p /run/foxos-theme
        echo "${config.foxos.themeMultiverse.selectedTheme}" > /run/foxos-theme/active
        echo "${toString (themeHelpers.extractThemeColors config.foxos.themeMultiverse.selectedTheme)}" > /run/foxos-theme/colors
      '';
      wantedBy = [ "multi-user.target" ];
    };
  };
}