#=============================================================================
# 🎨 THEME REGISTRY
# Updated to match actual directory structure
#=============================================================================

{
  # =============================================================================
  # GRUB THEMES
  # =============================================================================
  grub = {
    # DedSec GRUB Themes
    dragon-wannacry = {
      loader = "grub";
      source = ./themes/dedsec/grub/wannacry;
      resolution = "1440p";
    };
    
    darkmatter = {
      loader = "grub";
      source = ./themes/dedsec/darkmatter.nix;
    };
    
    # GRUB Template
    grubbedmouth-template = {
      loader = "grub";
      source = ./themes/dedsec/grub/templates;
    };
  };

  # =============================================================================
  # PLYMOUTH THEMES
  # =============================================================================
  plymouth = {
    # Dragon theme
    dragon = {
      loader = "plymouth";
      source = ./themes/plymouth/themes/dragon;
    };
    
    # Evil Nix Plymouth
    evil-nix = {
      loader = "plymouth";
      source = ./themes/plymouth/variants/evil-nix-plymouth;
    };
    
    # Rainbow Nix Plymouth
    rainbow-nix = {
      loader = "plymouth";
      source = ./themes/plymouth/variants/rainbow-nix-plymouth;
    };
    
    # Plymouth Template
    plymouth-template = {
      loader = "plymouth";
      source = ./themes/plymouth/template;
    };
  };

  # =============================================================================
  # REFIND THEMES
  # =============================================================================
  refind = {
    # Classic UI Themes
    classic = {
      catppuccin = {
        loader = "refind";
        source = ./themes/refind/classic-ui/catppuccin;
      };
      
      dracula = {
        loader = "refind";
        source = ./themes/refind/classic-ui/dracula;
      };
      
      nord = {
        loader = "refind";
        source = ./themes/refind/classic-ui/nord;
      };
      
      sweet-mars = {
        loader = "refind";
        source = ./themes/refind/classic-ui/sweet-mars;
      };
    };
    
    # AI Assistant Themes (DevPals)
    devpals = {
      chatgpt = {
        loader = "refind";
        source = ./themes/refind/devpals/chatgpt;
      };
      
      claude = {
        loader = "refind";
        source = ./themes/refind/devpals/claude;
      };
      
      deepseek-cosmic = {
        loader = "refind";
        source = ./themes/refind/devpals/deepseek;
        variant = "cosmic";
      };
      
      deepseek-legendary = {
        loader = "refind";
        source = ./themes/refind/devpals/deepseek;
        variant = "legendary";
      };
      
      gemini = {
        loader = "refind";
        source = ./themes/refind/devpals/gemini;
      };
      
      meta = {
        loader = "refind";
        source = ./themes/refind/devpals/meta;
      };
    };
    
    # FoxOS Themes
    foxos = {
      foxos-default = {
        loader = "refind";
        source = ./themes/refind/foxos/foxos-refind.nix;
      };
      
      mysticism = {
        astrology = {
          loader = "refind";
          source = ./themes/refind/foxos/foxos-mysticism/astrology.nix;
        };
        
        occult = {
          loader = "refind";
          source = ./themes/refind/foxos/foxos-mysticism/occult.nix;
        };
        
        tarot = {
          loader = "refind";
          source = ./themes/refind/foxos/foxos-mysticism/tarot.nix;
        };
      };
    };
    
    # Nyan Mode
    nyan = {
      nyancat = {
        loader = "refind";
        source = ./themes/refind/nyan-mode/nyancat.nix;
      };
      
      nyancat-refind = {
        loader = "refind";
        source = ./themes/refind/nyan-mode/nyancat-refind.nix;
      };
    };
    
    # rEFInd Templates
    templates = {
      template = {
        loader = "refind";
        source = ./themes/refind/refind-templates/re_theme-template.nix;
      };
      
      template-quick = {
        loader = "refind";
        source = ./themes/refind/refind-templates/re_theme-template_quick.nix;
      };
      
      dedmouth-redemption = {
        loader = "refind";
        source = ./themes/refind/refind-templates/re_dedmouth-redemption.nix;
      };
    };
  };

  # =============================================================================
  # COMBINED THEME SETS (Multi-loader coordination)
  # =============================================================================
  themeSets = {
    # DedSec complete set
    "dedsec-wannacry" = {
      grub = ./themes/dedsec/grub/wannacry;
      plymouth = ./themes/plymouth/themes/dragon;
      refind = null; # Not available
    };
    
    # DeepSeek Cosmic
    "deepseek-cosmic" = {
      grub = null;
      plymouth = ./themes/plymouth/variants/rainbow-nix-plymouth;
      refind = ./themes/refind/devpals/deepseek;
    };
    
    # DeepSeek Legendary
    "deepseek-legendary" = {
      grub = null;
      plymouth = ./themes/plymouth/themes/dragon;
      refind = ./themes/refind/devpals/deepseek;
    };
    
    # Claude Purple
    "claude-purple" = {
      grub = null;
      plymouth = ./themes/plymouth/variants/rainbow-nix-plymouth;
      refind = ./themes/refind/devpals/claude;
    };
    
    # Gemini Refined
    "gemini-refined" = {
      grub = null;
      plymouth = ./themes/plymouth/variants/rainbow-nix-plymouth;
      refind = ./themes/refind/devpals/gemini;
    };
    
    # Catppuccin
    "catppuccin-mocha" = {
      grub = null;
      plymouth = ./themes/plymouth/variants/evil-nix-plymouth;
      refind = ./themes/refind/classic-ui/catppuccin;
    };
    
    # Evil Nix theme set
    "evil-nix" = {
      grub = null;
      plymouth = ./themes/plymouth/variants/evil-nix-plymouth;
      refind = null;
    };
  };

  # =============================================================================
  # THEME METADATA
  # =============================================================================
  metadata = {
    grub = {
      supportedResolutions = [ "1440p" "1080p" "4k" ];
      defaultResolution = "1440p";
    };
    
    plymouth = {
      animationFrames = {
        dragon = 94; # progress-0.png to progress-93.png
        evil-nix = 30; # 001.png to 030.png
        rainbow-nix = 30; # 001.png to 030.png
      };
    };
    
    refind = {
      iconSets = {
        wannacry = [ "color" "white" ];
      };
    };
  };
}
