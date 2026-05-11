# Contributing

## Prerequisites

- Nix with flakes enabled
- direnv (recommended)

## Setup

```sh
git clone https://github.com/pr0d1r2/nixos-poe2.git
cd nixos-poe2
direnv allow   # or: nix develop
```

The dev shell provides all linters, formatters, and test tools.

## Development workflow

1. Enter dev shell (`direnv allow` or `nix develop`).
2. Configure preferences: `just config`.
3. Make changes, commit often (one decision per commit).
4. Run `just smoke` to verify the ISO boots correctly.
5. Run `just burn` to write to USB and test on hardware.

## Conventions

- **TDD**: write test first (RED), then implementation (GREEN), separate commits.
- **No shell functions**: split into separate scripts, call inline.
- **No embedded shell in nix**: extract to `fragments/` or `scripts/`.
- **No credentials in repo**: secrets go in `secrets/` (gitignored).
- **Justfile recipes**: alphabetical order, no embedded shell.
- **Commit messages**: short imperative summary, one topic per commit.

## Testing

```sh
just smoke     # QEMU boot test
bats tests/    # Unit tests
```

## Project layout

See `CLAUDE.md` for the full project structure and module descriptions.

## License

By contributing, you agree that your contributions will be licensed
under the MIT License.
