# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
    home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  #services.displayManager.defaultSession = "gnome";
  programs.hyprland = {
      enable = true;
      xwayland.enable = true;
  };
  
  programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
	    # Core dynamic linking & basics (almost always required)
	    stdenv.cc.cc.lib
	    zlib
	    expat
	    fontconfig
	    freetype

	    # Wayland – the most important ones for native Wayland support
	    wayland
	    wayland-protocols
	    libxkbcommon
	    libdrm
	    mesa              # provides libGL, libEGL, Vulkan – very often needed

	    # GTK (JetBrains IDEs often use GTK for some parts / themes / dialogs)
	    gtk3
	    # gtk4            # ← add if you see GTK4-related errors (rare for JetBrains)

	    # X11 compatibility layer (fallback / some dialogs / accessibility)
	   #xorg.libX11
	   #xorg.libXext
	   #xorg.libXrender
	   #xorg.libXtst
	   #xorg.libXcursor
	   #xorg.libXi

	    # Audio & misc
	    alsa-lib
	    at-spi2-core      # accessibility
	    libGL             # sometimes needed separately

	    # JetBrains / Java runtime common needs
	    nss
	    nspr
	    #openssl
	    curl
	    icu
    ]; 
  };
  environment.etc."hypr/hyprland.conf".text = ''
    exec-once = hyprpaper
    input {
        kb_layout = se
        kb_layout =
        kb_model =
        kb_options =
        kb_rules =
    }
  '';

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "se";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "sv-latin1";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.siglaz = {
    isNormalUser = true;
    description = "Jacob Sigling";
    extraGroups = [
        "networkmanager"
         "wheel"
         "tty"
         "dialout"
    ];
  };

  home-manager.useGlobalPkgs = true;
  home-manager.users.siglaz = {pkgs, config, ...}:
  {
    home.packages = with pkgs; [
        brave
        discord
        spotify
        libreoffice-fresh
        hunspell
        hunspellDicts.uk_UA
        jetbrains-toolbox
        steam-run
    ];
    home.sessionPath = [
        "${config.home.homeDirectory}/.local/share/JetBrains/Toolbox/scripts"
    ];

    services.hyprpaper = {
        enable = true;
        settings = {
            preload = ["~/Pictures/nixoswallpaper.png"];
            wallpaper = ["eDP-1,~/Pictures/nixoswallpaper.png"];
        };
    };

    wayland.windowManager.hyprland = {
        enable = true;
        settings= {
            input = {
                kb_layout = "se";
                kb_variant = "";
                kb_model = "";
                kb_options = "";
                kb_rules = "";
            };
            bind = [
                "SUPER, Q, exec, kitty"
                "SUPER, B, exec, brave"
                "SUPER, E, exit"
                "SUPER, L, spotify"
            ];
            xwayland.force_zero_scaling = true;
        };
    };

    home.stateVersion = "25.05";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    nixd
    kitty
    git
    fzf
    zoxide
    jq
  ];


  programs.dconf.profiles.user.databases = [
    {
        settings."org/gnome/desktop/interface" = {
            gtk-theme = "Adawaita";
            icon-theme = "Flat-Remix-Red-Dark";
            font-name = "Noto Sans Medium 11";
            document-font-name = "Noto Sans Medium 11";
            monospace-font-name = "Noto Sans Medium 11";
        };
    }
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
