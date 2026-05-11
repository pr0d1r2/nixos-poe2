# GGG installer staging directory

Place `PathOfExile2Installer.exe` here. It is NOT embedded in the ISO —
it gets uploaded to the live node via `just upload`.

## How to obtain it

1. Open <https://pathofexile2.com/download> in any browser.
2. Log into your GGG account.
3. Click **Standalone Client** → **PC** to download the `.exe`.
4. Place the downloaded file at:

   ```
   pkgs/installer/PathOfExile2Installer.exe
   ```

5. Boot the USB stick, then run `just upload` from your dev machine.

## Why isn't it in the repo?

The installer is GGG's intellectual property. You're allowed to download and
use it for yourself, but redistributing the binary in a public repo is a grey
area we'd rather not test. The `.gitignore` at the repo root excludes
`*.exe` from this directory, so you can drop the file in without accidentally
committing it.

## Will this installer go stale?

The `.exe` is a tiny (~5 MB) bootstrapper. It self-updates and downloads the
~100 GB game data on first run, so even an older installer file generally
works. Re-download it once a year or so to be safe.
