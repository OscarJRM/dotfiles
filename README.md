# ⚡ Personal Dotfiles & Neovim Configuration

Welcome to my personal developer environment and custom Neovim setup! This repository is configured for high-efficiency full-stack software development across **TypeScript**, **Angular**, **Java**, and **Microservices**.

---

## 🎨 Visual & Functional Highlights

* 🌙 **Theme:** TokyoNight (Storm style)
* 🚀 **Completion:** `blink.cmp` + Friendly Snippets
* 🤖 **AI Assistance:** GitHub Copilot (inline auto-suggestions)
* 🔍 **Fuzzy Search:** `telescope.nvim` with live LSP reference tracking & code previews
* 🛠️ **LSP Manager:** `mason.nvim` + `mason-lspconfig`
* 📁 **Explorer & Status:** `nvim-tree.lua` + `lualine.nvim`
* 📑 **Buffer Tabs:** `bufferline.nvim` + `bufdelete.nvim`
* ⚡ **Diagnostics:** Error-Lens style inline error text
* ⚡ **Code Folding:** `nvim-ufo` (VS Code-style fold preview)

---

## 🛠️ Supported Language Servers (LSP)

| Language | LSP Server | Notes |
| :--- | :--- | :--- |
| **TypeScript / JS** | `ts_ls` + `eslint` | ESLint v9 & legacy compatibility |
| **Angular** | `angularls` | Auto-scoped to projects with `angular.json` |
| **Java** | `nvim-jdtls` | Eclipse JDTLS + Lombok support |
| **HTML / CSS** | `html`, `cssls`, `emmet_ls` | Emmet snippet expansions |
| **Lua** | `lua_ls` | Neovim Lua API support |

---

## ⌨️ Keybindings Reference

| Mode | Shortcut | Action |
| :--- | :--- | :--- |
| **Normal** | `gd` | Go to Definition |
| **Normal** | `gr` | Go to References *(Telescope with live code preview)* |
| **Normal** | `K` | Hover Documentation / Fold preview |
| **Normal** | `<leader>ff` | Search Files *(Telescope)* |
| **Normal** | `<leader>fg` | Live Grep text search |
| **Normal** | `<leader>e` | Toggle File Explorer (`nvim-tree`) |
| **Normal** | `<leader>cf` | Format code (ESLint / Prettier / LSP) |
| **Normal** | `<Tab>` / `<S-Tab>` | Cycle next/prev buffer tab |
| **Normal** | `<leader>x` | Close active buffer tab |
| **Normal** | `<C-o>` / `<C-i>` | Jump Back / Jump Forward in history |

---

## 📦 Installation Guide

To use this configuration on any computer (macOS, Linux, or Windows):

### 🍎 macOS / 🐧 Linux:
```bash
# 1. Backup existing config (if any)
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null

# 2. Clone this repository directly into ~/.config/nvim
git clone git@github.com-ankairos:OscarJRM/dotfiles.git ~/.config/nvim

# 3. Open Neovim (lazy.nvim will automatically bootstrap plugins)
nvim
```

### 🪟 Windows (PowerShell):
```powershell
# Clone into AppData/Local/nvim
git clone git@github.com-ankairos:OscarJRM/dotfiles.git $env:LOCALAPPDATA\nvim

# Launch Neovim
nvim
```

---

## 📜 Author

**Oscar Joel Ramírez Manzano**  
GitHub: [@OscarJRM](https://github.com/OscarJRM)
