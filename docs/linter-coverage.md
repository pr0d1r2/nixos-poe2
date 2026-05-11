# Linter Coverage

| Extension | Linter | Notes |
|-----------|--------|-------|
| `.bats` | ShellCheck (via bats) | Test files |
| `.editorconfig` | EditorConfig | Config format |
| `.envrc` | direnv | Shell config |
| `.gitattributes` | - | Git LFS config |
| `.exp` | - | Expect scripts, no linter |
| `.gitignore` | - | Git config |
| `.gitkeep` | - | Empty directory marker |
| `.jsonc` | EditorConfig | JSON with comments |
| `.lock` | - | Nix flake lock |
| `.mp4` | - | Binary video, LFS-tracked |
| `.md` | markdownlint | Documentation |
| `.nix` | nixfmt, statix, deadnix | Nix expressions |
| `.nix-embedded-shell-allowlist` | - | Lefthook hook config |
| `.sh` | ShellCheck, shfmt | Shell scripts |
| `.shell-functions-allowlist` | - | Lefthook hook config |
| `.tcl` | tcl-syntax | Tcl scripts |
| `.tdd-order-baseline` | - | Lefthook hook config |
| `.toml` | taplo | Config format |
| `.yml` | yamllint | YAML config |
| `justfile` | justfile-alphabetical, justfile-no-embedded-shell | Task runner |
| `LICENSE` | - | Plain text, no linter needed |
