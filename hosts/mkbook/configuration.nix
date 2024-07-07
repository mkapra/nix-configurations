{ pkgs, inputs, ... }: {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.rectangle
    pkgs.raycast
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "x86_64-darwin";

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (inputs.nixpkgs.lib.getName pkg) [
    "raycast"
  ];

  fonts.packages = [ (pkgs.nerdfonts.override { fonts = ["FiraCode"]; }) ];

  homebrew.enable = true;
  homebrew.brews = [];
  homebrew.casks = [
    "bitwarden"
    "google-chrome"
    "obsidian"
    "signal"
    "virtualbox"
    "netbirdio/tap/netbird-ui"
  ];
  homebrew.global.autoUpdate = false;

  users.users.mkapra = {
    shell = pkgs.nushell;
  };

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
}
