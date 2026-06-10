# OS KNOWLEDGE BASE

## OVERVIEW

`os/` owns platform boundaries: shared dotfiles in `common`, automated macOS/Linux installers, a separate Ubuntu desktop profile, and manual Windows config storage.

## STRUCTURE

```text
os/
|-- common/     # reusable config linked by common installer
|-- macos/      # Homebrew and macOS app configs
|-- linux/      # Ubuntu/Debian VPS profile plus explicit desktop profile
`-- windows/    # manual Windows files; no automated installer
```

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| Shared zsh/tmux/editor config | `common/config/` | Linked into `$HOME` by `common/install.sh`. |
| macOS desktop setup | `macos/install.sh`, `macos/config/`, `macos/packages/` | Runs before common setup from root installer. |
| Linux VPS setup | `linux/install.sh`, `linux/README.md` | Root installer runs this by default on Linux. |
| Ubuntu desktop setup | `linux/desktop/install.sh`, `linux/desktop/README.md` | Root installer runs this only with `LINUX_PROFILE=desktop`. |
| Windows config | `windows/config/` | Manual application only. |

## CONVENTIONS

- Keep reusable config in `common`; do not duplicate common zsh/tmux/editor settings in platform folders.
- The root dispatcher is intentionally asymmetric: macOS runs `macos/install.sh` then `common/install.sh`; Linux defaults to `linux/install.sh`, while `LINUX_PROFILE=desktop` runs the desktop profile.
- Platform installers use Bash and should stay safe to rerun.
- Any new platform side effect needs both installer output and README/AGENTS documentation.

## ANTI-PATTERNS

- Do not add platform-specific app config to `common`.
- Do not make Windows look automated unless `install.sh` really handles it.
- Do not hide security, sudo, shell-change, desktop package-manager, or profile-specific side effects behind default behavior.

## COMMANDS

```bash
bash -n install.sh os/common/install.sh os/macos/install.sh os/linux/install.sh os/linux/desktop/install.sh
zsh -n os/common/config/zsh/.zshrc
zsh -n os/linux/config/zsh/.zshrc
tmux source-file -n os/common/config/tmux/.tmux.conf
tmux source-file -n os/linux/config/tmux/.tmux.conf
sway --validate --config os/linux/desktop/config/sway/config
```
