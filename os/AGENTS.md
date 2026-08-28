# OS KNOWLEDGE BASE

## OVERVIEW

`os/` owns platform boundaries: shared dotfiles in `common`, automated macOS and Ubuntu VPS installers, and manual Windows config storage.

## STRUCTURE

```text
os/
|-- common/     # reusable config linked by common installer
|-- macos/      # Homebrew and macOS app configs
|-- linux/      # Ubuntu/Debian VPS setup
`-- windows/    # manual Windows files; no automated installer
```

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| Shared zsh/tmux/editor config | `common/config/` | Linked into `$HOME` by `common/install.sh`. |
| macOS desktop setup | `macos/install.sh`, `macos/config/`, `macos/packages/` | Runs before common setup from root installer. |
| Linux VPS setup | `linux/install.sh`, `linux/README.md` | Root installer runs this on Linux. |
| Windows config | `windows/config/` | Manual application only. |

## CONVENTIONS

- Keep reusable config in `common`; do not duplicate common zsh/tmux/editor settings in platform folders.
- The root dispatcher is intentionally asymmetric: macOS runs `macos/install.sh` then `common/install.sh`; Linux runs only `linux/install.sh` for VPS setup.
- Platform installers use Bash and should stay safe to rerun.
- Any new platform side effect needs both installer output and README/AGENTS documentation.

## ANTI-PATTERNS

- Do not add platform-specific app config to `common`.
- Do not make Windows look automated unless `install.sh` really handles it.
- Do not hide security, sudo, or shell-change side effects behind default behavior.

## VALIDATION COMMANDS

```bash
bash -n install.sh os/common/install.sh os/macos/install.sh os/linux/install.sh os/linux/test-install.sh
bash os/linux/test-install.sh
bash -n os/common/config/bash/.bashrc os/common/config/bash/config/*.bash
zsh -n os/common/config/zsh/.zshrc
zsh -n os/linux/config/zsh/.zshrc
tmux -L dev-init-common-check -f /dev/null new-session -d -s check \; source-file -n os/common/config/tmux/.tmux.conf \; kill-server
tmux -L dev-init-linux-check -f /dev/null new-session -d -s check \; source-file -n os/linux/config/tmux/.tmux.conf \; kill-server
```
