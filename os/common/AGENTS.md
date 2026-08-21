# COMMON CONFIG KNOWLEDGE BASE

## OVERVIEW

`os/common/` contains cross-platform shell, editor, terminal, and font assets linked after macOS setup and by both Linux desktop profiles.

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| Shared install flow | `install.sh` | Links Bash, zsh, IdeaVim, Ghostty, Starship, tmux, and Zed config; installs fonts on macOS/Linux. |
| Bash entrypoint | `config/bash/.bashrc`, `config/bash/.bash_profile` | Loads ble.sh without immediate attach, sources guarded modules, then calls `ble-attach` last. |
| Bash modules | `config/bash/config/*.bash` | Linked individually by `install.sh`; local overrides belong in `~/.bashrc.local`. |
| zsh entrypoint | `config/zsh/.zshrc` | Keeps Kiro pre/post blocks at file boundaries and sources modules in dependency order. |
| zsh modules | `config/zsh/config/*.zsh` | Linked individually by `install.sh`. |
| tmux config | `config/tmux/.tmux.conf` | Validate with tmux dry parse. |
| Herdr config | `config/herdr/config.toml` | Tracked key/plugin reference; not linked by the common installer. |
| Editor/Vim config | `config/editors/`, `config/zed/` | Shared editor integration and Zed Vim mode. |
| Terminal/system config | `config/ghostty/`, `config/system/` | Ghostty, Starship, and a separate MCP client template. |
| Fonts | `assets/fonts/` | Copied to `~/Library/Fonts` on macOS and `~/.local/share/fonts` on Linux. |

## CONVENTIONS

- `install.sh` symlinks most config into `$HOME`; preserve idempotency and parent-directory creation.
- Both Linux desktop profiles run this installer; keep Linux font installation safe and guarded by `fc-cache` availability.
- Bash load order matters: ble.sh with `--attach=none`, modules, local overrides, Starship/zoxide/Herdr guards, then `ble-attach` last.
- zsh load order matters: Kiro pre block, modules, runtime tools, local overrides, Starship, guarded Herdr auto-start, then Kiro post block. The tmux auto-start block is intentionally disabled.
- Keep Kiro pre/post blocks at the top and bottom of `.zshrc`; Kiro updates rely on those boundaries.
- Keep private aliases, server names, tokens, and machine-specific values in `~/.bashrc.local` or `~/.zshrc.local`, not tracked files.
- `git-wrapper.sh` is made executable by the installer before linking.

## ANTI-PATTERNS

- Do not put platform-only app settings here.
- Do not make shell entrypoints depend on commands that may be absent without a `command -v` or file-exists guard.
- Do not commit real local overrides; `.bashrc.local.example` and `.zshrc.local.example` are templates only.
- Do not enable both tmux and Herdr auto-start in the same terminal path without rechecking nested-session guards.

## VALIDATION COMMANDS

```bash
bash -n os/common/install.sh os/common/config/bash/install.sh os/common/config/bash/.bashrc os/common/config/bash/config/*.bash os/common/config/zsh/install.sh
zsh -n os/common/config/zsh/.zshrc
tmux -L dev-init-common-check -f /dev/null new-session -d -s check \; source-file -n os/common/config/tmux/.tmux.conf \; kill-server
if command -v herdr >/dev/null; then HERDR_CONFIG_PATH="$PWD/os/common/config/herdr/config.toml" herdr config check; fi
```
