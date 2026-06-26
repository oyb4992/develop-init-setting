# LINUX VPS KNOWLEDGE BASE

## OVERVIEW

`os/linux/` contains the default Ubuntu/Debian VPS setup for OpenClaw operations plus an explicit Ubuntu GUI desktop install mode under `desktop/`.

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| Linux installer | `install.sh` | apt packages, config links, optional security, optional shell switch. |
| Usage docs | `README.md` | OpenClaw aliases and security behavior. |
| Desktop installer | `desktop/install.sh` | Ubuntu GUI setup selected with `LINUX_PROFILE=desktop`. |
| Desktop packages | `desktop/packages/` | APT, Flatpak, and Snap package lists for KDE Plasma. |
| Desktop config | `desktop/README.md` | KDE shortcut/panel configuration is documented as manual to avoid overwriting user state. |
| apt packages | `packages/apt.txt` | Installer filters unavailable packages before install. |
| zsh config | `config/zsh/.zshrc` | Server-oriented aliases and `OPENCLAW_DIR`. |
| tmux config | `config/tmux/.tmux.conf` | Linux/VPS tmux config. |
| SSH hardening | `config/ssh/sshd_config.example` | Example only; never applied automatically. |

## CONVENTIONS

- Installer assumes apt-based Ubuntu/Debian; unsupported package managers should fail clearly.
- VPS remains the default Linux install mode; desktop must require `LINUX_PROFILE=desktop`.
- Desktop uses KDE Plasma and may use Flatpak/Snap for GUI apps, with per-package failures reported as warnings.
- `APPLY_SECURITY=1` is required for ufw, fail2ban, and unattended-upgrades changes.
- `CHANGE_SHELL=1` is required before running `chsh`.
- Keep VPS aliases tied to `OPENCLAW_DIR` and Docker Compose operations.

## ANTI-PATTERNS

- Do not enable firewall/security defaults unless the env flag is set.
- Do not run desktop package installation from the default VPS path.
- Do not overwrite `/etc/ssh/sshd_config`; document review of the example instead.
- Do not copy macOS desktop assumptions into the server zsh/tmux config.

## COMMANDS

```bash
bash -n os/linux/install.sh os/linux/desktop/install.sh
zsh -n os/linux/config/zsh/.zshrc
tmux source-file -n os/linux/config/tmux/.tmux.conf
APPLY_SECURITY=1 CHANGE_SHELL=1 ./install.sh
LINUX_PROFILE=desktop ./install.sh
```
