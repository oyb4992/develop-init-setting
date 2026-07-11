# MACOS KNOWLEDGE BASE

## OVERVIEW

`os/macos/` owns Homebrew packages, macOS app configs, and installer steps with local desktop side effects.

## STRUCTURE

```text
macos/
|-- install.sh
|-- packages/       # Brewfile plus quarantine app list
`-- config/         # AeroSpace, Hammerspoon, Karabiner, PopClip, Raycast, BTT notes
```

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| macOS bootstrap | `install.sh` | Installs Homebrew packages and links app config, including the Docker MCP Gateway. |
| Docker MCP Gateway | `config/mcp/docker-gateway.sh`, `config/docker/mcp/config.yaml` | Colima Gateway wrapper with GitHub and filesystem servers; filesystem access is limited to `~/IdeaProjects`. |
| Homebrew packages | `packages/Brewfile` | Update with `brew bundle dump --force` when intentional. |
| Quarantine cleanup list | `packages/apps.txt` | Used only with `REMOVE_QUARANTINE=1`. |
| AeroSpace | `config/.aerospace.toml` | Validate with `aerospace reload-config --dry-run`. |
| Hammerspoon | `config/hammerspoon/*.lua` | Installer links sibling Lua files and tracked Spoons. |
| Karabiner | `config/karabiner/` | Has its own install script; copy/backup behavior differs from symlinks. |
| PopClip | `config/popClip/Extension/` | Bundles mix source, signatures, icons, generated artifacts, and `.skip`. |
| Raycast | `config/raycast/` | Includes backup config and script commands, some with Korean paths. |

## CONVENTIONS

- Keep `install.sh` Bash/idempotent; use `link_file` for files and `link_path` for directory-style app bundles.
- `REMOVE_QUARANTINE=1` is intentionally opt-in because it uses sudo and changes app metadata.
- Preserve Korean filenames in Raycast commands unless there is a user-facing reason to rename them.
- Hammerspoon modules are loaded from `init.lua`; keep module names and linked filenames consistent.
- Keep MCP secrets in the untracked `~/.config/mcp/github.env`; never add a token to the repository.

## ANTI-PATTERNS

- Do not commit untracked Hammerspoon Spoon installs; only tracked patched Spoons belong here.
- Do not treat PopClip signature or bundled output as normal source without checking the extension format.
- Do not add Homebrew changes without noting whether `Brewfile` was dumped or manually edited.
- Do not run quarantine removal by default.

## COMMANDS

```bash
bash -n os/macos/install.sh os/macos/config/karabiner/install.sh
brew bundle --file ./os/macos/packages/Brewfile
aerospace reload-config --dry-run
```
