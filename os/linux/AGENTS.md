# LINUX VPS KNOWLEDGE BASE

## OVERVIEW

`os/linux/` is an Ubuntu/Debian VPS profile for OpenClaw operations, separated from macOS desktop dotfiles.

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| Linux installer | `install.sh` | apt packages, config links, optional security, optional shell switch. |
| Usage docs | `README.md` | OpenClaw aliases and security behavior. |
| apt packages | `packages/apt.txt` | Installer filters unavailable packages before install. |
| zsh profile | `config/zsh/.zshrc` | Server-oriented aliases and `OPENCLAW_DIR`. |
| tmux profile | `config/tmux/.tmux.conf` | Linux/VPS tmux config. |
| SSH hardening | `config/ssh/sshd_config.example` | Example only; never applied automatically. |

## CONVENTIONS

- Installer assumes apt-based Ubuntu/Debian; unsupported package managers should fail clearly.
- `APPLY_SECURITY=1` is required for ufw, fail2ban, and unattended-upgrades changes.
- `CHANGE_SHELL=1` is required before running `chsh`.
- Keep VPS aliases tied to `OPENCLAW_DIR` and Docker Compose operations.

## ANTI-PATTERNS

- Do not enable firewall/security defaults unless the env flag is set.
- Do not overwrite `/etc/ssh/sshd_config`; document review of the example instead.
- Do not copy macOS desktop assumptions into the server zsh/tmux profile.

## COMMANDS

```bash
bash -n os/linux/install.sh
zsh -n os/linux/config/zsh/.zshrc
tmux source-file -n os/linux/config/tmux/.tmux.conf
APPLY_SECURITY=1 CHANGE_SHELL=1 ./install.sh
```
