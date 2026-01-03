{
  description = "My Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew,... }:
  let
    configuration = { pkgs, config, ... }: {

      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.allowBroken = true;

      system.primaryUser = "utkarshverma";

      homebrew = {
          enable = true;
          brews = [
            "kanata"
            "sshx"
            "rustup"
            "openssl"
            "rust-analyzer"
            "trash"
            "lazydocker"
            "rainfrog"
            "pnpm"
            "tylerbrock/saw/saw"
            "scrcpy"
            "opencode"
          ];
          casks = [
            "nikitabobko/tap/aerospace"
            "jandedobbeleer/oh-my-posh/oh-my-posh"
            "android-platform-tools"
            "ghostty"
            "legcord"
          ];
          onActivation.cleanup = "zap";
          onActivation.upgrade = true;
          onActivation.autoUpdate = true;
        };
      environment.systemPackages =
        [ pkgs.neovim
          pkgs.discord
          pkgs.raycast
          pkgs.tree
          pkgs.fastfetch
          pkgs.yazi
          pkgs.kitty
          pkgs.fish
          pkgs.nushell
          pkgs.tmux
          pkgs.httpie
          pkgs.stow
          pkgs.carapace
          pkgs.bat
          pkgs.lazygit
          pkgs.btop
          pkgs.fzf
          pkgs.jq
          pkgs.fd
          pkgs.sd
          pkgs.ripgrep
          pkgs.eza
          pkgs.zoxide
          pkgs.starship
          pkgs.pass
          pkgs.podman
          pkgs.podman-compose
          pkgs.gh
          pkgs.cmatrix
          pkgs.ffmpeg
          pkgs.inetutils
          pkgs.socat
          pkgs.kew
          # pkgs.pywal16
          pkgs.glow
          pkgs.gnupg
          pkgs.direnv
          pkgs.docker

          pkgs.awscli2
          pkgs.aws-sam-cli
          pkgs.cloudflared

          pkgs.nodePackages.npm
          pkgs.bun
          pkgs.codex
          pkgs.go
          pkgs.zig
          pkgs.uv
          pkgs.terraform

          pkgs.cmake
          pkgs.glfw
          pkgs.ninja
          pkgs.llvm
          pkgs.pkg-config
          pkgs.qemu

          pkgs.ruff

          pkgs.xh
          pkgs.hyperfine
          pkgs.tokei
          pkgs.just
          pkgs.presenterm
          pkgs.tmux-sessionizer

          pkgs.valkey
          pkgs.wabt
          pkgs.jdk

          pkgs.presenterm

        ];

      fonts.packages = [
          pkgs.nerd-fonts.jetbrains-mono
          pkgs.nerd-fonts.roboto-mono
        ];

      system.activationScripts.applications.text = let
      env = pkgs.buildEnv {
        name = "system-applications";
        paths = config.environment.systemPackages;
        pathsToLink = "/Applications";
      };
    in
      pkgs.lib.mkForce ''
        # Set up applications.
        echo "setting up /Applications..." >&2
        rm -rf /Applications/Nix\ Apps
        mkdir -p /Applications/Nix\ Apps
        find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while IFS= read -r src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done
      '';

      system.defaults = {
        dock.autohide = true;
                    dock.persistent-apps = [
                        "${pkgs.kitty}/Applications/Kitty.app"
                        "Applications/Legcord.app"
                    ];
        finder.FXPreferredViewStyle = "clmv";
        loginwindow.GuestEnabled = false;
        NSGlobalDomain.KeyRepeat = 2;
        NSGlobalDomain.AppleInterfaceStyle = "Dark";
      };
      # Auto upgrade nix package and the daemon service.
      # services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Utkarshs-MacBook-Pro
    darwinConfigurations."Utkarshs-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = "utkarshverma";
              # autoMigrate = true;
            #   taps = {
            #     "homebrew/homebrew-core" = homebrew-core;
            #     "homebrew/homebrew-cask" = homebrew-cask;
            #     "koekeishiya/formulae" = homebrew-koekeishiya;
            #   };
            };
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Utkarshs-MacBook-Pro".pkgs;
  };
}

