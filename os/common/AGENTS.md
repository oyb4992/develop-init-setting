# COMMON CONFIG KNOWLEDGE BASE

## OVERVIEW

`os/common/` contains cross-platform dotfiles and assets linked into the user home directory, mostly after macOS setup.

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| Shared install flow | `install.sh` | Links tracked config and installs macOS fonts. |
| zsh entrypoint | `config/zsh/.zshrc` | Sources modules from `~/.config/zsh` in dependency order. |
| zsh modules | `config/zsh/config/*.zsh` | Linked individually by `install.sh`. |
| tmux config | `config/tmux/.tmux.conf` | Validate with tmux dry parse. |
| Editor/Vim config | `config/editors/`, `config/zed/` | Shared editor integration and Zed Vim mode. |
| Terminal/system config | `config/ghostty/`, `config/kitty/`, `config/system/` | Ghostty, Kitty, Starship, Fastfetch, MCP config. |
| Fonts | `assets/fonts/` | Copied to `~/Library/Fonts` on macOS and `~/.local/share/fonts` on Linux. |

## CONVENTIONS

- `install.sh` symlinks most config into `$HOME`; preserve idempotency and parent-directory creation.
- Linux desktop runs this installer from `os/linux/desktop/install.sh`; keep Linux font installation safe and guarded by `fc-cache` availability.
- zsh module load order matters: `env`, `plugins`, `aliases`, `bindings`, `functions`, local overrides, Starship, tmux auto-start.
- Keep private aliases, server names, tokens, and machine-specific values in `~/.zshrc.local`, not tracked files.
- `git-wrapper.sh` is made executable by the installer before linking.

## ANTI-PATTERNS

- Do not put platform-only app settings here.
- Do not make `.zshrc` depend on commands that may be absent without a `command -v` or file-exists guard.
- Do not commit real local overrides; `.zshrc.local.example` is only a template.

## COMMANDS

```bash
bash -n os/common/install.sh os/common/config/zsh/install.sh os/common/config/kitty/install.sh
zsh -n os/common/config/zsh/.zshrc
tmux source-file -n os/common/config/tmux/.tmux.conf
```
