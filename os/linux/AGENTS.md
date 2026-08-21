# LINUX KNOWLEDGE BASE

## OVERVIEW

`os/linux/` contains the default Ubuntu/Debian VPS setup for OpenClaw operations, an existing-desktop development profile under `dev-desktop/`, and a full KDE Plasma profile under `desktop/`.

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| VPS installer | `install.sh` | apt packages, config links, optional security, optional shell switch. |
| Usage docs | `README.md` | OpenClaw aliases and security behavior. |
| Development desktop installer | `dev-desktop/install.sh` | Development tools and common dotfiles selected with `LINUX_PROFILE=dev-desktop`. |
| Development desktop packages | `dev-desktop/packages/apt.txt` | APT-only tool list; no KDE, display manager, Flatpak, or Snap install. |
| KDE desktop installer | `desktop/install.sh` | Ubuntu GUI setup selected with `LINUX_PROFILE=desktop`. |
| Desktop packages | `desktop/packages/` | APT, Flatpak, and Snap package lists for KDE Plasma. |
| Desktop config | `desktop/README.md` | KDE shortcut/panel configuration is documented as manual to avoid overwriting user state. |
| apt packages | `packages/apt.txt` | Installer filters unavailable packages before install. |
| zsh config | `config/zsh/.zshrc` | Server-oriented aliases and `OPENCLAW_DIR`. |
| tmux config | `config/tmux/.tmux.conf` | Linux/VPS tmux config. |
| SSH hardening | `config/ssh/sshd_config.example` | Example only; never applied automatically. |

## CONVENTIONS

- Installer assumes apt-based Ubuntu/Debian; unsupported package managers should fail clearly.
- VPS remains the default Linux install mode; desktop profiles require `LINUX_PROFILE=dev-desktop` or `LINUX_PROFILE=desktop`.
- `dev-desktop` preserves the existing desktop environment and installs APT development tools only.
- `desktop` installs KDE Plasma and may use Flatpak/Snap for GUI apps, with per-package failures reported as warnings.
- `APPLY_SECURITY=1` is required for ufw, fail2ban, and unattended-upgrades changes.
- `CHANGE_SHELL=1` is required before running `chsh`.
- Keep VPS aliases tied to `OPENCLAW_DIR` and Docker Compose operations.

## ANTI-PATTERNS

- Do not enable firewall/security defaults unless the env flag is set.
- Do not run either desktop package installation from the default VPS path.
- Do not overwrite `/etc/ssh/sshd_config`; document review of the example instead.
- Do not copy macOS desktop assumptions into the server zsh/tmux config.

## VALIDATION COMMANDS

```bash
bash -n os/linux/install.sh os/linux/test-install.sh os/linux/dev-desktop/install.sh os/linux/desktop/install.sh
bash os/linux/test-install.sh
zsh -n os/linux/config/zsh/.zshrc
tmux -L dev-init-linux-check -f /dev/null new-session -d -s check \; source-file -n os/linux/config/tmux/.tmux.conf \; kill-server
```

## MUTATING COMMANDS

Run only for the profile or side effect the user explicitly requests.

```bash
APPLY_SECURITY=1 CHANGE_SHELL=1 ./install.sh
LINUX_PROFILE=dev-desktop ./install.sh
LINUX_PROFILE=desktop ./install.sh
```
