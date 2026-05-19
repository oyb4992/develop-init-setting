# Repository Guidelines

## Project Structure & Module Organization

This repository manages personal development environment bootstrap files across operating systems. The top-level `install.sh` detects the host OS and dispatches to platform installers. Shared dotfiles and assets live in `os/common/`, macOS-specific packages and app configs live in `os/macos/`, Linux VPS setup lives in `os/linux/`, and Windows configs live in `os/windows/` for manual use. Local Docker services are under `services/`, currently `services/n8n/`. General notes belong in `docs/` or the root `README.md`.

## Build, Test, and Development Commands

- `./install.sh`: run the OS-aware bootstrap flow.
- `APPLY_SECURITY=1 CHANGE_SHELL=1 ./install.sh`: apply Linux VPS security defaults and switch the shell to zsh.
- `brew bundle --file ./os/macos/packages/Brewfile`: install macOS packages without running the full installer.
- `zsh -n os/common/config/zsh/.zshrc`: check common zsh syntax.
- `tmux source-file -n os/common/config/tmux/.tmux.conf`: validate tmux configuration.
- `aerospace reload-config --dry-run`: validate macOS AeroSpace config when available.
- `docker compose -f services/n8n/docker-compose.yml up -d`: start the local n8n service.

## Coding Style & Naming Conventions

Shell scripts use Bash with `set -euo pipefail`, two- or four-space indentation consistent with the surrounding file, and small helper functions such as `link_file`. Keep install scripts idempotent: prefer symlinking tracked config files and guard destructive or privileged actions behind environment flags. Store platform-specific files under the matching OS directory; put reusable editor, shell, terminal, and font assets under `os/common/`.

## Testing Guidelines

There is no centralized test suite. Before committing, run syntax or dry-run checks for the files you touched. For shell changes, run `bash -n path/to/script.sh` and, where safe, execute the script in a disposable environment. For config changes, use the owning tool's validation command. Do not commit generated local state such as `venv/`, `.DS_Store`, editor caches, or `services/n8n/data/`.

## Commit & Pull Request Guidelines

Recent history follows short Conventional Commit-style messages, for example `fix(zsh): eza 추가` and `feat(linux): add openclaw vps profile`. Use `feat`, `fix`, `refactor`, or `docs`, with a scope when useful. Pull requests should describe the affected OS/tool, list validation commands run, and call out any manual steps, screenshots, or security-impacting changes.

## Security & Configuration Tips

Never commit secrets, tokens, private `.env` files, runtime databases, or machine-specific credentials. Treat firewall, shell, Homebrew, and `sudo` changes as high-impact; document the required environment flags and expected side effects.
