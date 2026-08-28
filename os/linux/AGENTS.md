# LINUX KNOWLEDGE BASE

## OVERVIEW

`os/linux/` contains the Ubuntu/Debian VPS setup for OpenClaw operations.

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| VPS installer | `install.sh` | apt packages, config links, optional security, optional shell switch. |
| Usage docs | `README.md` | OpenClaw aliases and security behavior. |
| apt packages | `packages/apt.txt` | Installer filters unavailable packages before install. |
| zsh config | `config/zsh/.zshrc` | Server-oriented aliases and `OPENCLAW_DIR`. |
| tmux config | `config/tmux/.tmux.conf` | Linux/VPS tmux config. |
| SSH hardening | `config/ssh/sshd_config.example` | Example only; never applied automatically. |

## CONVENTIONS

- Installer assumes apt-based Ubuntu/Debian; unsupported package managers should fail clearly.
- The root dispatcher runs this VPS installer for Linux without alternate profiles.
- `APPLY_SECURITY=1` is required for ufw, fail2ban, and unattended-upgrades changes.
- `CHANGE_SHELL=1` is required before running `chsh`.
- Keep VPS aliases tied to `OPENCLAW_DIR` and Docker Compose operations.

## ANTI-PATTERNS

- Do not enable firewall/security defaults unless the env flag is set.
- Do not overwrite `/etc/ssh/sshd_config`; document review of the example instead.
- Do not copy macOS desktop assumptions into the server zsh/tmux config.

## VALIDATION COMMANDS

```bash
bash -n os/linux/install.sh os/linux/test-install.sh
bash os/linux/test-install.sh
zsh -n os/linux/config/zsh/.zshrc
tmux -L dev-init-linux-check -f /dev/null new-session -d -s check \; source-file -n os/linux/config/tmux/.tmux.conf \; kill-server
```

## MUTATING COMMANDS

Run only for the profile or side effect the user explicitly requests.

```bash
APPLY_SECURITY=1 CHANGE_SHELL=1 ./install.sh
```
