{
  description = "Bootable NixOS USB pendrive -- boots straight to PoE 2. No desktop, no Steam.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    nix-lefthook-ascii-only = {
      url = "github:pr0d1r2/nix-lefthook-ascii-only";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-bats-changed = {
      url = "github:pr0d1r2/nix-lefthook-bats-changed";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-lefthook-bats-failures-only.follows = "nix-lefthook-bats-failures-only";
    };
    nix-lefthook-bats-failures-only = {
      url = "github:pr0d1r2/nix-lefthook-bats-failures-only";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-bats-parse = {
      url = "github:pr0d1r2/nix-lefthook-bats-parse";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-bats-unit = {
      url = "github:pr0d1r2/nix-lefthook-bats-unit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-commit-msg-lint = {
      url = "github:pr0d1r2/nix-lefthook-commit-msg-lint";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-deadnix = {
      url = "github:pr0d1r2/nix-lefthook-deadnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-editorconfig-checker = {
      url = "github:pr0d1r2/nix-lefthook-editorconfig-checker";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-execute-permissions = {
      url = "github:pr0d1r2/nix-lefthook-execute-permissions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-file-size-check = {
      url = "github:pr0d1r2/nix-lefthook-file-size-check";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-gawk-lint = {
      url = "github:pr0d1r2/nix-lefthook-gawk-lint";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-git-conflict-markers = {
      url = "github:pr0d1r2/nix-lefthook-git-conflict-markers";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-git-no-local-paths = {
      url = "github:pr0d1r2/nix-lefthook-git-no-local-paths";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-gitleaks = {
      url = "github:pr0d1r2/nix-lefthook-gitleaks";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-justfile-alphabetical = {
      url = "github:pr0d1r2/nix-lefthook-justfile-alphabetical";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-justfile-no-embedded-shell = {
      url = "github:pr0d1r2/nix-lefthook-justfile-no-embedded-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-linter-coverage = {
      url = "github:pr0d1r2/nix-lefthook-linter-coverage";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-markdownlint = {
      url = "github:pr0d1r2/nix-lefthook-markdownlint";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-missing-final-newline = {
      url = "github:pr0d1r2/nix-lefthook-missing-final-newline";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-nix-no-embedded-shell = {
      url = "github:pr0d1r2/nix-lefthook-nix-no-embedded-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-nixfmt = {
      url = "github:pr0d1r2/nix-lefthook-nixfmt";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-no-shell-functions = {
      url = "github:pr0d1r2/nix-lefthook-no-shell-functions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-pre-rebase-merged-commits = {
      url = "github:pr0d1r2/nix-lefthook-pre-rebase-merged-commits";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-shellcheck = {
      url = "github:pr0d1r2/nix-lefthook-shellcheck";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-shfmt = {
      url = "github:pr0d1r2/nix-lefthook-shfmt";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-statix = {
      url = "github:pr0d1r2/nix-lefthook-statix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-taplo = {
      url = "github:pr0d1r2/nix-lefthook-taplo";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-tdd-order-bats = {
      url = "github:pr0d1r2/nix-lefthook-tdd-order-bats";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-tcl-syntax = {
      url = "github:pr0d1r2/nix-lefthook-tcl-syntax";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-trailing-whitespace = {
      url = "github:pr0d1r2/nix-lefthook-trailing-whitespace";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-typos = {
      url = "github:pr0d1r2/nix-lefthook-typos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-unicode-lint = {
      url = "github:pr0d1r2/nix-lefthook-unicode-lint";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-xmllint = {
      url = "github:pr0d1r2/nix-lefthook-xmllint";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-yamllint = {
      url = "github:pr0d1r2/nix-lefthook-yamllint";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems f;

      system = "x86_64-linux";

    in
    {
      nixosConfigurations.nixos-poe2 = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ./modules/audio.nix
          ./modules/base.nix
          ./modules/gaming.nix
          ./modules/hardware.nix
          ./modules/poe2.nix
          ./modules/users.nix
          ./modules/avahi.nix
          ./modules/ssh.nix
          ./modules/builder.nix
          ./modules/storage/nvme.nix
          ./modules/storage/sata.nix
          ./modules/storage/link.nix
          ./modules/storage/overlay.nix
          ./modules/storage/proton.nix
          ./modules/machine-id.nix
          ./modules/mumble.nix
        ];
      };

      packages.${system} = {
        iso = self.nixosConfigurations.nixos-poe2.config.system.build.isoImage;
        default = self.packages.${system}.iso;
      };

      devShells = forAllSystems (
        system:
        let
          devPkgs = nixpkgs.legacyPackages.${system};

          hookPackages =
            with devPkgs;
            [
              git
              just
              bats
              parallel
              lefthook
              shellcheck
              deadnix
              editorconfig-checker
              nixfmt-rfc-style
              shfmt
              typos
              yamllint
            ]
            ++ [
              inputs.nix-lefthook-ascii-only.packages.${system}.default
              inputs.nix-lefthook-bats-changed.packages.${system}.default
              inputs.nix-lefthook-bats-failures-only.packages.${system}.default
              inputs.nix-lefthook-bats-parse.packages.${system}.default
              inputs.nix-lefthook-bats-unit.packages.${system}.default
              inputs.nix-lefthook-commit-msg-lint.packages.${system}.default
              inputs.nix-lefthook-deadnix.packages.${system}.default
              inputs.nix-lefthook-editorconfig-checker.packages.${system}.default
              inputs.nix-lefthook-execute-permissions.packages.${system}.default
              inputs.nix-lefthook-file-size-check.packages.${system}.default
              inputs.nix-lefthook-gawk-lint.packages.${system}.default
              inputs.nix-lefthook-git-conflict-markers.packages.${system}.default
              inputs.nix-lefthook-git-no-local-paths.packages.${system}.default
              inputs.nix-lefthook-gitleaks.packages.${system}.default
              inputs.nix-lefthook-justfile-alphabetical.packages.${system}.default
              inputs.nix-lefthook-justfile-no-embedded-shell.packages.${system}.default
              inputs.nix-lefthook-linter-coverage.packages.${system}.default
              inputs.nix-lefthook-markdownlint.packages.${system}.default
              inputs.nix-lefthook-missing-final-newline.packages.${system}.default
              inputs.nix-lefthook-nix-no-embedded-shell.packages.${system}.default
              inputs.nix-lefthook-nixfmt.packages.${system}.default
              inputs.nix-lefthook-no-shell-functions.packages.${system}.default
              inputs.nix-lefthook-pre-rebase-merged-commits.packages.${system}.default
              inputs.nix-lefthook-shellcheck.packages.${system}.default
              inputs.nix-lefthook-shfmt.packages.${system}.default
              inputs.nix-lefthook-statix.packages.${system}.default
              inputs.nix-lefthook-taplo.packages.${system}.default
              inputs.nix-lefthook-tdd-order-bats.packages.${system}.default
              inputs.nix-lefthook-tcl-syntax.packages.${system}.default
              inputs.nix-lefthook-trailing-whitespace.packages.${system}.default
              inputs.nix-lefthook-typos.packages.${system}.default
              inputs.nix-lefthook-unicode-lint.packages.${system}.default
              inputs.nix-lefthook-xmllint.packages.${system}.default
              inputs.nix-lefthook-yamllint.packages.${system}.default
            ];

          interactivePackages = with devPkgs; [
            pv
            asciinema
            asciinema-agg
            ffmpeg
          ];
        in
        {
          default = devPkgs.mkShell {
            buildInputs = hookPackages ++ interactivePackages;
            shellHook = ''
              source ${./nix/dev/shell.sh}
            '';
          };

          ci = devPkgs.mkShell {
            buildInputs = hookPackages;
          };
        }
      );
    };
}
