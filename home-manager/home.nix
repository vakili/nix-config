# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, lib, config, pkgs, nur, ... }:

let
  addons = pkgs.nur.repos.rycee.firefox-addons;
in
{
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors), use something like:
    # inputs.nix-colors.homeManagerModule

    # Feel free to split up your configuration and import pieces of it here.
  ];

  # Comment out if you wish to disable unfree packages for your system
  nixpkgs.config.allowUnfree = true;

  home = {
    username = "infty";
    homeDirectory = "/home/infty";
    sessionVariables = {
      NIX_CONFIG = "experimental-features = nix-command flakes";
      FOO = "foo";
    };
    packages = with pkgs;
      [
        age
        fd
        ripgrep
        nixpkgs-fmt
        dzen2
        light
        acpi
        age
        pandoc
        redshift
        tree
        xsel
        ranger
        feh
        vim
      ];
  };
  programs = {
    firefox = {
      enable = true;
      extensions = 
        with addons; [
          ublock-origin
        ];
    };
    home-manager.enable = true;
    git = {
      enable = true;
      extraConfig = {
        init.defaultBranch = "main";
      };
    };
    bash = {
      enable = true;
      historyFileSize = 1000000000000;
    };
    skim = {
      enable = true;
      enableBashIntegration = true;
    };
    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };
    kitty = {
      enable = true;
      extraConfig = "
        confirm_os_window_close 0
      ";
    };
    qutebrowser.enable = true;
    neovim = {
      enable = true;
      extraConfig = "
        set clipboard+=unnamedplus
      ";
    };
    rofi.enable = true;
  };
  xsession = {
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.05";

  home.file.backgroundImage = {
    source = ../misc/background-image;
    target = ".background-image";
  };
  
  xdg = {
    configFile = {
      xmonad = {
        source = ../config/xmonad;
        recursive = true;
      };
      qutebrowser = {
        source = ../config/qutebrowser;
        recursive = true;
      };
    };
  };
}
