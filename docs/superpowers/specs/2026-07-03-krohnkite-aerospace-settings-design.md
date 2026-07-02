# Krohnkite AeroSpace-Style Settings Design

## Goal

Add a KDE Plasma 6 settings bundle that translates the practical parts of
`os/macos/config/.aerospace.toml` to Krohnkite and KWin without replacing the
user's complete KDE configuration.

The bundle must remain opt-in. The existing Ubuntu KDE desktop installer keeps
installing Krohnkite, but only applies these settings when
`APPLY_KROHNKITE_CONFIG=1` is set.

## Scope

The implementation covers:

- Krohnkite layout, gap, floating, and window-filter settings.
- AeroSpace-style focus, move, layout, floating, close, and virtual desktop
  shortcuts.
- Ten KDE virtual desktops named `A`, `B`, `C`, `D`, `F`, `I`, `N`, `T`, `W`,
  and `Z`.
- A non-applied `kwinrulesrc.example` containing editable application routing
  examples.
- Backup, validation, application, and post-install documentation.

It does not automatically import application routing rules. Linux window
classes and KDE virtual desktop identifiers vary by installed application and
machine, so importing guessed values would create incorrect or stale rules.

## Files

### `os/linux/desktop/config/krohnkite/kwinrc`

A tracked KConfig fragment containing only the groups and keys owned by this
setup:

- Krohnkite is enabled in the KWin plugins group.
- The default layout is Spread, the closest Krohnkite equivalent to
  AeroSpace's accordion layout.
- Tile layout remains available through a shortcut.
- Inner and outer screen gaps are set to 5 pixels.
- Krohnkite's upstream default ignore classes are preserved.
- Layout state is kept separately per virtual desktop.
- Separate screen focus is enabled for multi-monitor navigation.

The file is a fragment and must never be symlinked over `~/.config/kwinrc`.

### `os/linux/desktop/config/krohnkite/kglobalshortcutsrc`

A tracked KConfig fragment containing only Krohnkite and KWin shortcut entries.
It maps:

- `Alt+H/J/K/L` to directional focus.
- `Alt+Shift+H/J/K/L` to directional window movement.
- `Alt+/` to Tile and `Alt+,` to Spread.
- `Alt+Shift+Space` to floating toggle.
- `Alt+Ctrl+Q` to close the focused window.
- `Alt+A/B/C/D/F/I/N/T/W/Z` to the corresponding KDE virtual desktop.
- `Alt+Shift+A/B/C/D/F/I/N/T/W/Z` to move the focused window to that desktop.

Krohnkite operations that have no safe equivalent are not invented. In
particular, the AeroSpace reload shortcut is omitted because Krohnkite upstream
requires a reboot after configuration changes and warns against toggling the
script off and on.

The file is a fragment and must never be symlinked over
`~/.config/kglobalshortcutsrc`.

### `os/linux/desktop/config/krohnkite/kwinrulesrc.example`

A commented, non-applied KWin rules template for application-to-desktop
routing. It mirrors the semantic AeroSpace groups:

- AI applications to `A`.
- Browsers to `B`.
- Chat and mail applications to `C`.
- Documentation and API clients to `D`.
- File managers to `F`.
- IDEs and editors to `I`.
- Note applications to `N`.
- Terminals to `T`.
- Virtual machines to `W`.
- Optional unmatched applications to `Z`.

Each example includes placeholders for the Linux window class and KDE virtual
desktop identifier. The accompanying documentation explains how to inspect a
window with KWin's Window Rules dialog and replace those placeholders. Floating
examples are included for communication and utility applications, but no rule
is imported automatically.

### `os/linux/desktop/apply-krohnkite-config.sh`

This script is the only writer for the tracked fragments. It:

1. Refuses to run as root because KDE configuration is user-scoped.
2. Requires `python3`, `kwriteconfig6`, and an installed Krohnkite package.
3. Creates timestamped backups of existing `kwinrc` and
   `kglobalshortcutsrc` beside the originals when those files exist.
4. Reads the tracked KConfig fragments with Python's interpolation-free
   `configparser.RawConfigParser` and writes only their declared groups and
   keys through `kwriteconfig6`.
5. Leaves all unrelated KDE settings unchanged.
6. Reports the optional `kwinrulesrc.example` path without importing it.
7. Instructs the user to reboot after successful application.

The script does not toggle Krohnkite or restart KWin.

## Installer Flow

`os/linux/desktop/install.sh` continues to install Krohnkite first. After a
successful or already-present installation:

- With `APPLY_KROHNKITE_CONFIG=1`, it runs
  `apply-krohnkite-config.sh`.
- Otherwise, it prints the opt-in command and leaves KDE settings untouched.

A configuration failure produces a warning and preserves the backups. It does
not prevent the remaining Flatpak, Snap, or shell setup from running.

## Safety

- No complete KDE state file is linked or replaced.
- Application rules remain examples until the user verifies local window
  classes and desktop identifiers.
- Backups are created before the first write.
- Repeated application writes the same values and is idempotent.
- The VPS installer and the default unset Linux profile remain unaffected.

## Verification

Static verification:

- `bash -n os/linux/desktop/install.sh`
- Syntax-check the new apply script.
- `git diff --check`
- Parse both tracked KConfig fragments with the same structured parser used by
  the apply script.

Behavioral verification with temporary HOME and command mocks:

- The default installer path does not apply KDE settings.
- `APPLY_KROHNKITE_CONFIG=1` invokes the apply script.
- Root execution is rejected.
- Missing `kwriteconfig6` or Krohnkite fails before any write.
- Existing files are backed up.
- Only declared groups and keys are passed to `kwriteconfig6`.
- A second run produces the same effective settings.
- The KWin rules example is never imported.

Manual KDE Plasma verification remains required on Ubuntu 26.04:

- Reboot and confirm Krohnkite is enabled.
- Confirm Spread is the initial layout and gaps are visible.
- Exercise focus, move, layout, floating, close, and desktop shortcuts.
- Verify all ten semantic desktop names.
- Copy one sample application rule, replace its local identifiers, and confirm
  that a new window opens on the intended desktop.
