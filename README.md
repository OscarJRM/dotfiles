# Dotfiles & Neovim Configuration

A personal, production-ready Neovim environment tailored for full-stack TypeScript, Angular, Java, and microservice architectures.

---

## Overview

This repository contains the configuration for a fast, keyboard-driven development environment built on top of native Neovim APIs and `lazy.nvim`. It integrates Language Server Protocols (LSP), Treesitter syntax highlighting, asynchronous completion, and interactive reference tracking.

### Core Features

* **Completion & AI:** Asynchronous completion powered by `blink.cmp` with inline GitHub Copilot suggestions.
* **Fuzzy Finder:** `telescope.nvim` configured with live code preview and full reference tracking (`gr`).
* **LSP Integration:** Pre-configured language servers for TypeScript (`ts_ls`), Angular (`angularls`), Java (`jdtls`), HTML/CSS, and Lua (`lua_ls`).
* **UI & Ergonomics:** TokyoNight Storm theme, `lualine.nvim` statusline, `bufferline.nvim` tabs, and `nvim-ufo` code folding.

---

## Language Servers & Tooling

| Language / Framework | Server | Highlights |
| :--- | :--- | :--- |
| **TypeScript / JS** | `ts_ls`, `eslint` | Full TypeScript diagnostics & ESLint validation |
| **Angular** | `angularls` | Scoped to projects containing `angular.json` |
| **Java** | `nvim-jdtls` | Eclipse JDTLS with Lombok agent support |
| **Markup & Styles** | `html`, `cssls`, `emmet_ls` | Emmet snippet expansion & CSS validation |
| **Lua** | `lua_ls` | Native Neovim runtime diagnostics |

---

## Key Mappings

### LSP & Code Navigation
* `gd` — Jump to Definition
* `gr` — Find References (Telescope with live code preview)
* `K` — Hover Documentation / Code fold preview
* `<C-o>` / `<C-i>` — Jump Backward / Forward in cursor history

### Workspace & Explorer
* `<leader>ff` — Find Files (Telescope)
* `<leader>fg` — Live Grep text search
* `<leader>e` — Toggle File Explorer (`nvim-tree`)

### Formatting & Buffers
* `<Tab>` / `<S-Tab>` — Cycle Next / Previous buffer tab
* `<leader>x` — Close current buffer tab
* `<leader>xo` — Close all OTHER buffer tabs
* `<leader>xa` — Close ALL buffer tabs
* `<leader>cf` — Format document (ESLint / Prettier / LSP)

### Code Folding (nvim-ufo)
* `zc` — Collapse / Fold current block
* `zo` — Expand / Open current block
* `za` — Toggle fold (Open / Close)
* `zM` — Collapse ALL blocks in file
* `zR` — Expand ALL blocks in file

---

## Installation

### macOS / Linux
```bash
git clone git@github.com-ankairos:OscarJRM/dotfiles.git ~/.config/nvim
nvim
```

### Windows (PowerShell)
```powershell
git clone git@github.com-ankairos:OscarJRM/dotfiles.git $env:LOCALAPPDATA\nvim
nvim
```

---

## Author

**Oscar Joel Ramírez Manzano**  
GitHub: [@OscarJRM](https://github.com/OscarJRM)
