# PROJECT KNOWLEDGE BASE

## OVERVIEW

Personal dotfiles/bootstrap repository for macOS desktop setup, Ubuntu VPS and desktop development profiles, manual Windows configs, shared shell/editor/terminal assets, and a local n8n Docker service.

## STRUCTURE

```text
dev-init-setting/
|-- install.sh              # OS detector and dispatcher
|-- os/
|   |-- common/             # reusable dotfiles/assets linked into $HOME
|   |-- macos/              # Homebrew packages and macOS app configs
|   |-- linux/              # Ubuntu/Debian VPS setup
|   |   |-- dev-desktop/    # existing desktop development tools
|   |   `-- desktop/        # KDE Plasma desktop setup
|   `-- windows/            # manual-only Windows configs
|-- services/n8n/           # compose/docs/templates; data is runtime state
|-- docs/                   # general notes
`-- README.md               # user-facing install and maintenance guide
```

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| Top-level bootstrap flow | `install.sh` | macOS runs macOS then common; Linux supports `vps`, `dev-desktop`, and `desktop`; Windows is manual. |
| Shared shell/editor/terminal config | `os/common/` | Symlinked dotfiles and copied font assets. Both Linux desktop profiles reuse this installer. |
| macOS packages and app config | `os/macos/` | Homebrew, AeroSpace, Hammerspoon, Karabiner, PopClip, Raycast. |
| Ubuntu VPS setup | `os/linux/` | apt packages, zsh/tmux config, SSH hardening example, security gates. |
| Existing Ubuntu desktop development setup | `os/linux/dev-desktop/` | APT development tools and common dotfiles without installing KDE/Flatpak/Snap. |
| Ubuntu GUI desktop setup | `os/linux/desktop/` | KDE Plasma desktop packages, KDE portal, shared dotfiles, Flatpak/Snap package lists. |
| Windows manual config | `os/windows/` | Not automated by `install.sh`. |
| Local n8n service | `services/n8n/` | Track compose, docs, `.env.example`, and the empty home shim; ignore data and local `.env`. |
| General docs | `README.md`, `docs/` | Update README tree when structure changes. |

## CODE MAP

| Surface | Type | Location | Role |
| --- | --- | --- | --- |
| `detect_os` | Bash function | `install.sh` | Maps `uname -s` to `macos`, `linux`, `windows`, or `unsupported`. |
| `link_file` | Bash helper | `os/common/install.sh`, `os/macos/install.sh`, `os/linux/install.sh` | Creates parent dirs and force-symlinks tracked config into `$HOME`. |
| `link_path` | Bash helper | `os/macos/install.sh` | Symlinks paths and backs up existing non-file/non-link targets. |
| `install_apt_packages` | Bash function | `os/linux/install.sh`, `os/linux/dev-desktop/install.sh`, `os/linux/desktop/install.sh` | Filters apt package lists against current sources before install. |
| `install_flatpak_packages` | Bash function | `os/linux/desktop/install.sh` | Registers Flathub and installs GUI Flatpak apps. |
| `install_snap_packages` | Bash function | `os/linux/desktop/install.sh` | Installs Snap GUI apps and warns on per-app failure. |
| `configure_security` | Bash function | `os/linux/install.sh` | Applies ufw/fail2ban/unattended-upgrades only with `APPLY_SECURITY=1`. |
| `configure_shell` | Bash function | `os/linux/install.sh`, `os/linux/dev-desktop/install.sh`, `os/linux/desktop/install.sh` | Runs `chsh` only with `CHANGE_SHELL=1`. |
| `remove_quarantine_attribute` | Bash function | `os/macos/install.sh` | Uses sudo/xattr only with `REMOVE_QUARANTINE=1`. |

## CONVENTIONS

- Shell scripts are Bash with `set -euo pipefail`; keep helper style close to existing `link_file` functions.
- Installers must remain idempotent. Prefer symlinking tracked config, and gate destructive or privileged actions behind explicit env flags.
- Shared assets belong in `os/common/`; platform-only files belong under the matching `os/<platform>/` directory.
- Linux profiles assume apt-based Ubuntu/Debian. Only the full `desktop` profile uses Flatpak/Snap for GUI apps.
- Commit messages use short Conventional Commit style, often with scopes such as `fix(zsh): ...` or `feat(linux): ...`.

## ANTI-PATTERNS

- Do not commit secrets, tokens, private `.env` files, runtime DBs, caches, or machine credentials.
- Do not treat `services/n8n/data/` or n8n backups as source material.
- Do not automate Windows setup unless the dispatcher and docs are updated together.
- Do not apply firewall, shell, Homebrew, quarantine, desktop package-manager, or sudo side effects without explicit user intent and documented impact.
- Do not overwrite SSH daemon config automatically; `os/linux/config/ssh/sshd_config.example` is review material.

## VALIDATION COMMANDS

```bash
bash -n install.sh os/common/install.sh os/macos/install.sh os/linux/install.sh os/linux/test-install.sh os/linux/dev-desktop/install.sh os/linux/desktop/install.sh
bash os/linux/test-install.sh
bash -n os/common/config/bash/.bashrc os/common/config/bash/config/*.bash
zsh -n os/common/config/zsh/.zshrc
zsh -n os/linux/config/zsh/.zshrc
tmux -L dev-init-common-check -f /dev/null new-session -d -s check \; source-file -n os/common/config/tmux/.tmux.conf \; kill-server
tmux -L dev-init-linux-check -f /dev/null new-session -d -s check \; source-file -n os/linux/config/tmux/.tmux.conf \; kill-server
aerospace reload-config --dry-run
brew bundle check --file ./os/macos/packages/Brewfile --no-upgrade
git clean -ndX
```

## MUTATING COMMANDS

Run only when the user explicitly requests the matching install or runtime change.

```bash
./install.sh
APPLY_SECURITY=1 CHANGE_SHELL=1 ./install.sh
LINUX_PROFILE=dev-desktop ./install.sh
LINUX_PROFILE=desktop ./install.sh
brew bundle --file ./os/macos/packages/Brewfile
docker compose -f services/n8n/docker-compose.yml up -d
```

## NOTES

- There is no centralized test suite; validate the touched surface with its owning tool.
- `services/n8n/.env` and runtime data are ignored. `services/n8n/.env.example` and `dummy_home/.gitkeep` are tracked bootstrap artifacts.
- Existing working-tree changes may be user edits; do not revert unrelated modified files.
