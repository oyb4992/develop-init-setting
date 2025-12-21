# AGENTS.md

This file provides guidance to AI agents working in this repository.

## Project Overview

This is a dotfiles and environment setup repository. It consists of shell scripts, configuration files, and several TypeScript-based Raycast extensions.

## Essential Commands

### Raycast Extension Development
Run these commands from within a specific extension's directory (e.g., `os/macos/config/raycast/raycast_command/Naver-Dictionary-Raycast-main`):

- **Build:** `npm run build`
- **Lint:** `npm run lint`
- **Auto-fix linting issues:** `npm run fix-lint`
- **Development mode:** `npm run dev`

There are no top-level build or test commands. For Raycast extensions, there are no explicit test commands. Please add tests if you are modifying an extension.

## Code Style Guidelines

### TypeScript/JavaScript (for Raycast extensions)

- **Formatting:** We use Prettier for code formatting. Adhere to the `.prettierrc` file (`printWidth: 120`, `singleQuote: false`).
- **Linting:** We use ESLint. Adhere to the `.eslintrc.json` file.
- **Imports:** Keep imports organized and clean.
- **Naming:** Use camelCase for variables and functions, and PascalCase for classes and components.
- **Error Handling:** Implement proper error handling for network requests and file system operations.
