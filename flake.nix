{
  description = "MacBook configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [
        pkgs.netbird-ui
        pkgs.rectangle
      ];

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "x86_64-darwin";

      fonts.fontDir.enable = true;
      fonts.fonts = [ (pkgs.nerdfonts.override { fonts = ["FiraCode"]; }) ];

      homebrew.enable = true;
      homebrew.brews = [];
      homebrew.casks = [
        "bitwarden"
        "google-chrome"
        "obsidian"
        "signal"
        "virtualbox"
      ];
      homebrew.global.autoUpdate = false;

      networking.computerName = "mkBook";

      nix.gc.automatic = true;
      nix.optimise.automatic = true;

      system.defaults.dock.autohide = true;
      system.defaults.dock.orientation = "bottom";
      system.defaults.dock.tilesize = 49;
      system.defaults.dock.persistent-apps = [
        # Finder is already default
        "/System/Applications/Launchpad.app"
        "/Applications/Google Chrome.app"
        "/Applications/iTerm.app"
        "/System/Applications/Mail.app"
        "/System/Applications/Calendar.app"
        "/System/Applications/Messages.app"
        "/System/Applications/Reminders.app"
        "/System/Applications/Notes.app"
        "/System/Applications/Music.app"
      ];

      system.defaults.finder.CreateDesktop = false;
      system.defaults.finder.ShowPathbar = true;
      system.defaults.finder.ShowStatusBar = true;

      system.defaults.trackpad.Clicking = true;
      system.defaults.NSGlobalDomain.InitialKeyRepeat = 14;
      system.defaults.NSGlobalDomain.KeyRepeat = 1;

      system.startup.chime = false;

      time.timeZone = "Europe/Berlin";
      # TODO:
      # Install: Discord, Kitty, gimp-with-plugins, wireshark
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#mkBook
    darwinConfigurations."mkBook" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users.mkapra = {
            home.homeDirectory = nixpkgs.lib.mkForce "/Users/mkapra";
            imports = [ ./modules/home-manager ];
          };
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."mkBook".pkgs;
  };
}
