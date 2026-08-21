-- 1. Bootstrap Lazy.nvim (The installation part)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Disable netrw for nvim-tree compatibility
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Angular component HTML filetype and Treesitter detection
vim.filetype.add({
  pattern = {
    [".*%.component%.html"] = "htmlangular",
    [".*%.template%.html"] = "htmlangular",
  },
})
vim.treesitter.language.register('angular', 'htmlangular')

-- Automatically start Treesitter for htmlangular files
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'htmlangular',
  callback = function()
    vim.treesitter.start()
  end,
})

-- Telescope previewer compatibility for Neovim Treesitter API differences
do
  vim.treesitter = vim.treesitter or {}
  vim.treesitter.language = vim.treesitter.language or {}

  if type(vim.treesitter.language.ft_to_lang) ~= 'function' then
    vim.treesitter.language.ft_to_lang = function(ft)
      if type(vim.treesitter.language.get_lang) == 'function' then
        return vim.treesitter.language.get_lang(ft) or ft
      end

      local ok, parsers = pcall(require, 'nvim-treesitter.parsers')
      if ok and type(parsers.ft_to_lang) == 'function' then
        return parsers.ft_to_lang(ft) or ft
      end

      return ft
    end
  end
end

-- 2. Define your Plugins (Adding Telescope for Cmd+P)
require("lazy").setup({
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('tokyonight').setup({
        style = 'night',
        transparent = false,
        terminal_colors = true,
      })
      vim.cmd.colorscheme('tokyonight-night')
    end,
  },
  {
    'nvim-tree/nvim-web-devicons',
    config = function()
      require('nvim-web-devicons').setup({
        override = {
          ["service.ts"] = { icon = "󰌆", color = "#e0af68", name = "ServiceTs" },
          ["controller.ts"] = { icon = "⚙", color = "#e0af68", name = "ControllerTs" },
          ["module.ts"] = { icon = "󰏗", color = "#f7768e", name = "ModuleTs" },
          ["spec.ts"] = { icon = "🧪", color = "#0db9d7", name = "SpecTs" },
          ["dto.ts"] = { icon = "󰈙", color = "#7dcfff", name = "DtoTs" },
          ["entity.ts"] = { icon = "󰆼", color = "#bb9af7", name = "EntityTs" },
        },
      })
    end,
  },
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('nvim-tree').setup({
        on_attach = function(bufnr)
          local api = require('nvim-tree.api')
          api.config.mappings.default_on_attach(bufnr)
          vim.keymap.set('n', '-', '<cmd>wincmd p<CR>', { buffer = bufnr, desc = 'Jump back to code window' })
        end,
        filters = {
          dotfiles = false,
          git_ignored = false,
        },
        diagnostics = {
          enable = true,
          show_on_dirs = true,
          show_on_open_dirs = true,
          severity = {
            min = vim.diagnostic.severity.HINT,
            max = vim.diagnostic.severity.ERROR,
          },
          icons = {
            hint = '✦',
            info = 'ℹ',
            warning = '⚠',
            error = '✗',
          },
        },
      })
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    config = function()
      require('lualine').setup({
        options = {
          theme = 'tokyonight',
          component_separators = { left = '|', right = '|' },
          section_separators = { left = '', right = '' },
        },
      })
    end,
  },
  {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require('bufferline').setup({
        options = {
          mode = "buffers",
          diagnostics = "nvim_lsp",
          diagnostics_indicator = function(count, level, diagnostics_dict, context)
            local s = " "
            for e, n in pairs(diagnostics_dict) do
              local sym = e == "error" and "✗ " or (e == "warning" and "⚠ " or "ℹ ")
              s = s .. sym .. n
            end
            return s
          end,
          offsets = {
            {
              filetype = "NvimTree",
              text = "File Explorer",
              text_align = "left",
              separator = true,
            }
          },
          show_buffer_close_icons = true,
          show_close_icon = true,
          persist_buffer_sort = true,
        }
      })
    end,
  },
  {
    'famiu/bufdelete.nvim',
  },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      local ok, ts_configs = pcall(require, 'nvim-treesitter.configs')
      if not ok then
        return
      end

      local ok_parsers, parsers = pcall(require, 'nvim-treesitter.parsers')
      if ok_parsers and type(parsers.ft_to_lang) ~= 'function' then
        parsers.ft_to_lang = function(ft)
          if vim.treesitter and vim.treesitter.language and type(vim.treesitter.language.get_lang) == 'function' then
            return vim.treesitter.language.get_lang(ft) or ft
          end
          return ft
        end
      end

      ts_configs.setup({
        ensure_installed = { 'lua', 'typescript', 'javascript', 'html', 'css', 'json', 'angular' },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup({
        defaults = {
          preview = {
            treesitter = false,
          },
        },
        pickers = {
          lsp_references = {
            include_declaration = true,
            include_current_line = true,
          },
        },
      })
    end,
  },
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup({
        update_debounce = 100,
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
        current_line_blame = true,
        current_line_blame_opts = { delay = 200, virt_text_pos = 'eol' },
        current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
      })
    end,
  },
  -- Completion setup with blink.cmp
  {
    'saghen/blink.cmp',
    version = '1.*',
    lazy = false, -- Load early for completion
    dependencies = {
      'rafamadriz/friendly-snippets',
    },
    opts = {
      enabled = function()
        -- Disable in command mode
        return vim.fn.mode() ~= 'c'
      end,
      cmdline = {
        enabled = true,
      },
      keymap = {
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
        ['<Tab>'] = {
          function(cmp)
            local ok, copilot = pcall(require, "copilot.suggestion")
            if ok and copilot.is_visible() then
              copilot.accept()
              return true
            end
          end,
          'select_next',
          'fallback',
        },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
        ['<CR>'] = { 'select_and_accept', 'fallback' },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'normal',
      },
      completion = {
        accept = {
          auto_brackets = {
            enabled = true,
          },
        },
        menu = {
          draw = {
            components = {
              kind_icon = {
                text = function(ctx)
                  local kind_icon = ctx.kind_icon
                  local kind = ctx.kind
                  -- If no kind icon, return empty
                  if not kind_icon then
                    return ''
                  end
                  -- Return icon with space
                  return kind_icon .. ' '
                end,
              },
            },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
        ghost_text = {
          enabled = true,
        },
      },
      signature = {
        enabled = true,
      },
      fuzzy = {
        implementation = 'rust',
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
    },
  },
  {
    'mg979/vim-visual-multi',
    branch = 'master',
  },
  -- GitHub Copilot inline suggestions (keeps blink.cmp as primary completion menu)
  {
    'zbirenbaum/copilot.lua',
    event = 'InsertEnter',
    cmd = 'Copilot',
    opts = {
      panel = {
        enabled = false,
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = true,
        keymap = {
          accept = false,
          next = false,
          prev = false,
          dismiss = false,
        },
      },
      filetypes = {
        markdown = true,
        help = false,
      },
    },
  },
  -- Mason for LSP server management (setup first, without auto-loading mason-lspconfig)
  {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    dependencies = {
      'neovim/nvim-lspconfig',
    },
    config = function()
      require('mason').setup({
        ui = {
          border = 'rounded',
          icons = {
            package_installed = '✓',
            package_pending = '➜',
            package_uninstalled = '✗',
          },
        },
        log_level = vim.log.levels.INFO,
        max_concurrent_installers = 4,
      })
    end,
  },
  -- mason-lspconfig: loaded after mason via lazy loading trigger
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig',
    },
    -- Ensure this loads after mason is set up
    lazy = false,
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "html", "cssls", "ts_ls", "lua_ls", "emmet_ls", "angularls", "eslint" },
        automatic_installation = true,
        automatic_enable = false,
      })
    end,
  },
  -- LSP Config (Neovim 0.11+ uses vim.lsp.config)
  {
    'neovim/nvim-lspconfig',
    lazy = false,
  },
  -- Java LSP wrapper (handles jdtls lifecycle correctly)
  {
    'mfussenegger/nvim-jdtls',
    ft = { 'java' },
  },
  {
    'mhinz/vim-signify',
    init = function()
      vim.g.signify_sign_add = '+'
      vim.g.signify_sign_change = '~'
      vim.g.signify_sign_delete = '_'
      vim.g.signify_vcs_cmds = {
        svn = 'svn diff --diff-cmd diff -x -U0 -- %f',
      }
    end,
    config = function()
      vim.keymap.set('n', '<leader>st', '<cmd>SignifyToggle<CR>', { desc = 'Signify toggle' })
      vim.keymap.set('n', ']s', '<cmd>SignifyHunkNext<CR>', { desc = 'Signify next hunk' })
      vim.keymap.set('n', '[s', '<cmd>SignifyHunkPrev<CR>', { desc = 'Signify prev hunk' })

      vim.api.nvim_set_hl(0, 'SignifySignAdd', { link = 'DiffAdd' })
      vim.api.nvim_set_hl(0, 'SignifySignChange', { link = 'DiffChange' })
      vim.api.nvim_set_hl(0, 'SignifySignDelete', { link = 'DiffDelete' })
    end,
  },
  {
    "weirongxu/plantuml-previewer.vim",
    dependencies = {
      "aklt/plantuml-syntax",
      "tyru/open-browser.vim"
    },
    cmd = "PlantumlOpen",
    keys = {
      { "<leader>po", "<cmd>PlantumlOpen<cr>", desc = "Open PlantUML Preview" },
      { "<leader>ps", "<cmd>PlantumlSave<cr>", desc = "Save PlantUML Diagram" }
    },
    init = function()
      vim.g['plantuml_previewer#plantuml_cmd_path'] = '/opt/homebrew/bin/plantuml'
    end
  },
  {
    'lervag/vimtex',
    ft = { 'tex', 'latex', 'bib' },
    init = function()
      vim.g.vimtex_view_method = 'skim'
      vim.g.vimtex_compiler_method = 'tectonic'
      vim.g.vimtex_compiler_tectonic = {
        build_dir = '',
        options = {
          '--synctex',
          '--keep-logs',
          '--keep-intermediates',
        },
      }
      vim.g.vimtex_quickfix_mode = 2
      vim.g.vimtex_mappings_enabled = 1
      vim.g.vimtex_indent_enabled = 1
      vim.g.vimtex_syntax_enabled = 1
    end,
    config = function()
      vim.keymap.set('n', '<leader>lc', '<cmd>VimtexCompile<CR>', { desc = 'LaTeX compile' })
      vim.keymap.set('n', '<leader>lv', '<cmd>VimtexView<CR>', { desc = 'LaTeX view PDF' })
      vim.keymap.set('n', '<leader>lk', '<cmd>VimtexStop<CR>', { desc = 'LaTeX stop compile' })
      vim.keymap.set('n', '<leader>le', '<cmd>VimtexErrors<CR>', { desc = 'LaTeX show errors' })
    end,
  },
  {
    'akinsho/git-conflict.nvim',
    version = "*",
    config = function()
      require('git-conflict').setup({
        default_mappings = true,
        default_commands = true,
        disable_diagnostics = false,
        list_opener = 'copen',
        highlights = {
          incoming = 'DiffAdd',
          current = 'DiffText',
        }
      })
    end
  },
  -- Code folding (VS Code-like collapse/expand)
  {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    config = function()
      require('ufo').setup({
        -- Use treesitter first, then LSP as fallback, then indent
        provider_selector = function(bufnr, filetype, buftype)
          return { 'lsp', 'indent' }
        end,
        -- Show number of folded lines + a preview of the content (like VS Code)
        fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
          local newVirtText = {}
          local suffix = ('  ↙ %d lines'):format(endLnum - lnum)
          local sufWidth = vim.fn.strdisplaywidth(suffix)
          local targetWidth = width - sufWidth
          local curWidth = 0
          for _, chunk in ipairs(virtText) do
            local chunkText = chunk[1]
            local chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if targetWidth > curWidth + chunkWidth then
              table.insert(newVirtText, chunk)
            else
              chunkText = truncate(chunkText, targetWidth - curWidth)
              local hlGroup = chunk[2]
              table.insert(newVirtText, { chunkText, hlGroup })
              chunkWidth = vim.fn.strdisplaywidth(chunkText)
              if curWidth + chunkWidth < targetWidth then
                suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
              end
              break
            end
            curWidth = curWidth + chunkWidth
          end
          table.insert(newVirtText, { suffix, 'MoreMsg' })
          return newVirtText
        end,
      })
      -- Keymaps for folding
      vim.keymap.set('n', 'zR', require('ufo').openAllFolds, { desc = 'Open all folds' })
      vim.keymap.set('n', 'zM', require('ufo').closeAllFolds, { desc = 'Close all folds' })
      vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds, { desc = 'Open folds except kinds' })
      vim.keymap.set('n', 'K', function()
        local winid = require('ufo').peekFoldedLinesUnderCursor()
        if not winid then
          vim.lsp.buf.hover()
        end
      end, { desc = 'Peek fold or hover' })
    end,
  },
})

-- 3. Set your Keybindings
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {}) -- Search Files
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})  -- Search Text inside files
vim.keymap.set('n', '<leader>gs', builtin.git_status, { desc = 'Git status (Telescope)' })
vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', { desc = 'Toggle file explorer' })
vim.keymap.set('n', '-', function()
  if vim.bo.filetype == 'NvimTree' then
    vim.cmd('wincmd p')
  else
    vim.cmd('NvimTreeFindFile')
  end
end, { desc = 'Toggle focus between code and file explorer' })

-- Format code using ESLint (Prettier) or LSP
vim.keymap.set('n', '<leader>cf', function()
  if vim.fn.exists(':EslintFixAll') == 2 then
    vim.cmd("EslintFixAll")
  else
    vim.lsp.buf.format({ async = true })
  end
end, { desc = 'Format code (ESLint/Prettier)' })

-- Bufferline navigation (tab switching)
vim.keymap.set('n', '<Tab>', '<cmd>BufferLineCycleNext<CR>', { desc = 'Next buffer tab' })
vim.keymap.set('n', '<S-Tab>', '<cmd>BufferLineCyclePrev<CR>', { desc = 'Previous buffer tab' })
vim.keymap.set('n', '<leader>x', '<cmd>Bdelete<CR>', { desc = 'Close buffer tab' })
vim.keymap.set('n', '<leader>xo', '<cmd>BufferLineCloseOthers<CR>', { desc = 'Close all other buffer tabs' })
vim.keymap.set('n', '<leader>xa', '<cmd>bufdo Bdelete<CR>', { desc = 'Close all buffer tabs' })
vim.keymap.set('n', '<leader>bl', '<cmd>BufferLineMoveMoveNext<CR>', { desc = 'Move tab right' })
vim.keymap.set('n', '<leader>bh', '<cmd>BufferLineMoveMousePrev<CR>', { desc = 'Move tab left' })

-- Copilot inline suggestion keymaps (insert mode)
vim.keymap.set('i', '<C-g><C-a>', function()
  require('copilot.suggestion').accept()
end, { desc = 'Copilot accept suggestion' })
vim.keymap.set('i', '<C-g><C-n>', function()
  require('copilot.suggestion').next()
end, { desc = 'Copilot next suggestion' })
vim.keymap.set('i', '<C-g><C-p>', function()
  require('copilot.suggestion').prev()
end, { desc = 'Copilot previous suggestion' })
vim.keymap.set('i', '<C-g><C-x>', function()
  require('copilot.suggestion').dismiss()
end, { desc = 'Copilot dismiss suggestion' })

vim.opt.number = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 100
vim.opt.signcolumn = "yes"
vim.opt.autoread = true

-- Code folding options (required by nvim-ufo)
vim.opt.foldcolumn = '1'       -- show fold indicator column
vim.opt.foldlevel = 99         -- start with all folds open
vim.opt.foldlevelstart = 99    -- open all folds when opening a file
vim.opt.foldenable = true      -- enable folding
-- Persist fold state per file (remembers what you had open/closed)
vim.opt.viewoptions = 'folds,cursor,curdir'
vim.api.nvim_create_autocmd('BufWinLeave', {
  pattern = '*',
  callback = function()
    if vim.fn.expand('%') ~= '' and vim.bo.buftype == '' then
      vim.cmd('silent! mkview')
    end
  end,
})
vim.api.nvim_create_autocmd('BufWinEnter', {
  pattern = '*',
  callback = function()
    if vim.fn.expand('%') ~= '' and vim.bo.buftype == '' then
      vim.cmd('silent! loadview')
    end
  end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  command = "if mode() != 'c' | checktime | endif",
  pattern = "*",
})

-- Press <leader> + h to clear search highlights
vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear search highlights" })

-- Telescope diagnostics (shows all errors/warnings with counts per file)
vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Find diagnostics" })

-- Quickfix: dump all workspace diagnostics into quickfix list (shows counts)
vim.keymap.set("n", "<leader>d", function()
  vim.diagnostic.setqflist({ open = true })
end, { desc = "Open diagnostics in quickfix" })

-- Diagnostic display — Error Lens style (visible inline messages)
vim.diagnostic.config({
  virtual_text = {
    prefix = '●',
    source = 'if_many',
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '✗',
      [vim.diagnostic.severity.WARN] = '⚠',
      [vim.diagnostic.severity.INFO] = 'ℹ',
      [vim.diagnostic.severity.HINT] = '✦',
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = 'if_many',
  },
})

-- Brighter diagnostic virtual text colors
vim.cmd([[
  highlight DiagnosticVirtualTextError cterm=italic gui=italic guifg=#db4b4b
  highlight DiagnosticVirtualTextWarn  cterm=italic gui=italic guifg=#e0af68
  highlight DiagnosticVirtualTextInfo  cterm=italic gui=italic guifg=#0db9d7
  highlight DiagnosticVirtualTextHint  cterm=italic gui=italic guifg=#9ece6a
]])

-- LSP Configuration - defer until after plugins are loaded
-- Using vim.lsp.config (Neovim 0.11+ native API) to avoid deprecated lspconfig framework
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    -- Get mason-lspconfig (optional - for automatic server installation)
    local mason_ok, mason_lspconfig = pcall(require, 'mason-lspconfig')
    
    -- Default LSP capabilities for blink.cmp
    local capabilities = vim.tbl_deep_extend(
      'force',
      {},
      vim.lsp.protocol.make_client_capabilities(),
      require('blink.cmp').get_lsp_capabilities()
    )
    -- nvim-ufo: tell LSP servers we support foldingRange
    capabilities.textDocument.foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true,
    }
    
    -- Common on_attach function for LSP
    local function on_attach(client, bufnr)
      -- Enable document formatting
      client.server_capabilities.documentFormattingProvider = true
      client.server_capabilities.documentRangeFormattingProvider = true

      -- Set keymaps for LSP
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition', buffer = bufnr })
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'Go to declaration', buffer = bufnr })
      vim.keymap.set('n', 'gr', function()
        require('telescope.builtin').lsp_references({ include_declaration = true, include_current_line = true })
      end, { desc = 'Go to references (Telescope)', buffer = bufnr })
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = 'Go to implementation', buffer = bufnr })
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover', buffer = bufnr })
      vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code action', buffer = bufnr })
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename', buffer = bufnr })
    end
    
    -- Get server configurations from lspconfig.util (avoids the deprecated lspconfig table)
    local util_ok, util = pcall(require, 'lspconfig.util')
    local lspconfig_root_dir = util and util.root_pattern or function() end
    
    -- Define LSP server configurations using vim.lsp.config (Neovim 0.11+)
    local lspconfig = vim.lsp.config
    
    -- Helper to get default config from nvim-lspconfig server definitions
    local function get_server_config(server_name)
      -- Try to get from lspconfig's server config
      local ok, server_config = pcall(require, 'lspconfig.configs.' .. server_name)
      if ok and server_config then
        if server_config.default_config then
          return server_config.default_config
        elseif server_config.document_config then
          return server_config.document_config.default_config
        end
      end
      return nil
    end
    
    -- Configure html LSP
    local html_config = get_server_config('html')
    if html_config then
      lspconfig.html = {
        cmd = html_config.cmd,
        filetypes = html_config.filetypes,
        capabilities = capabilities,
        on_attach = on_attach,
      }
      vim.lsp.enable('html')
    end
    
    -- Configure cssls LSP
    local cssls_config = get_server_config('cssls')
    if cssls_config then
      lspconfig.cssls = {
        cmd = cssls_config.cmd,
        filetypes = cssls_config.filetypes,
        capabilities = capabilities,
        on_attach = on_attach,
      }
      vim.lsp.enable('cssls')
    end
    
    -- Configure emmet_ls LSP
    local emmet_config = get_server_config('emmet_ls')
    if emmet_config then
      lspconfig.emmet_ls = {
        cmd = emmet_config.cmd,
        filetypes = {
          'html',
          'htmldjango',
          'javascript',
          'javascriptreact',
          'typescriptreact',
          'svelte',
          'vue',
        },
        capabilities = capabilities,
        on_attach = on_attach,
      }
      vim.lsp.enable('emmet_ls')
    end

    -- Configure eslint LSP (using legacy mode for ESLint v9/eslintrc.json compatibility)
    local eslint_config = get_server_config('eslint')
    if eslint_config then
      lspconfig.eslint = {
        cmd = eslint_config.cmd,
        filetypes = eslint_config.filetypes,
        capabilities = capabilities,
        on_attach = on_attach,
        cmd_env = {
          ESLINT_USE_FLAT_CONFIG = "false",
        },
      }
      vim.lsp.enable('eslint')
    end

    -- Configure angularls LSP
    local angularls_config = get_server_config('angularls')
    if angularls_config then
      local tsdk_path = vim.fs.find('node_modules/typescript/lib', { upward = true })[1]
      local local_ngserver = vim.fs.find('node_modules/.bin/ngserver', { upward = true })[1]
      
      local cmd = angularls_config.cmd
      if local_ngserver then
        cmd = {
          local_ngserver,
          '--stdio',
          '--tsProbeLocations',
          tsdk_path and vim.fs.dirname(tsdk_path) or '',
          '--ngProbeLocations',
          tsdk_path and vim.fs.dirname(tsdk_path) or '',
        }
      end

      lspconfig.angularls = {
        cmd = cmd,
        root_dir = util and util.root_pattern('angular.json', 'project.json'),
        filetypes = { 'typescript', 'html', 'typescriptreact', 'typescript.tsx', 'htmlangular' },
        capabilities = capabilities,
        on_attach = on_attach,
        init_options = tsdk_path and {
          typescript = {
            tsdk = tsdk_path,
          },
        } or nil,
        get_language_id = function(bufnr, filetype)
          return filetype == 'htmlangular' and 'html' or filetype
        end,
      }
      vim.lsp.enable('angularls')
    end
    
    -- Configure ts_ls LSP
    local ts_ls_config = get_server_config('ts_ls')
    if ts_ls_config then
      lspconfig.ts_ls = {
        cmd = ts_ls_config.cmd,
        filetypes = ts_ls_config.filetypes,
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
          on_attach(client, bufnr)
        end,
      }
      vim.lsp.enable('ts_ls')
    end
    
    -- Configure lua_ls LSP
    local lua_ls_config = get_server_config('lua_ls')
    if lua_ls_config then
      lspconfig.lua_ls = {
        cmd = lua_ls_config.cmd,
        filetypes = lua_ls_config.filetypes,
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          Lua = {
            runtime = {
              version = 'LuaJIT',
            },
            diagnostics = {
              globals = { 'vim' },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file('', true),
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
          },
        },
      }
      vim.lsp.enable('lua_ls')
    end
    
    -- If mason-lspconfig is available, ensure the servers are installed
    if mason_ok then
      mason_lspconfig.setup({
        ensure_installed = {
          'html',
          'cssls',
          'ts_ls',
          'lua_ls',
          'emmet_ls',
          'jdtls',
          'angularls',
          'eslint',
        },
        automatic_installation = true,
        automatic_enable = false,
      })
    end
  end,
  once = true,
})

-- Keymap to open Mason
vim.keymap.set('n', '<leader>lm', '<cmd>Mason<CR>', { desc = 'Open Mason LSP manager' })

-- Reveal current file or argument in macOS Finder
vim.api.nvim_create_user_command('Reveal', function(opts)
  local target = opts.args ~= '' and vim.fn.expand(opts.args) or vim.fn.expand('%:p')
  vim.fn.system({ 'open', '-R', target })
end, { desc = 'Reveal file in macOS Finder', nargs = '?', complete = 'file' })

vim.keymap.set('n', '<leader>or', '<cmd>Reveal<CR>', { desc = 'Reveal file in Finder' })
vim.keymap.set('n', '<leader>od', '<cmd>Reveal %:p:h<CR>', { desc = 'Open dir in Finder' })

local function populate_svn_changes(include_unversioned)
  vim.cmd('checktime')
  local lines = vim.fn.systemlist({ 'svn', 'status' })
  if vim.v.shell_error ~= 0 then
    vim.notify('svn status failed', vim.log.levels.ERROR)
    return
  end

  local allowed = { M = true, A = true, D = true, R = true, C = true, ['!'] = true }
  local items = {}

  for _, line in ipairs(lines) do
    local file_status = line:sub(1, 1)
    local prop_status = line:sub(2, 2)
    if allowed[file_status] or prop_status == 'M' or (include_unversioned and file_status == '?') then
      local path = vim.trim(line:sub(9))
      if path ~= '' then
        table.insert(items, {
          filename = path,
          lnum = 1,
          text = string.format('svn %s%s', file_status, prop_status),
        })
      end
    end
  end

  local title = include_unversioned and 'SVN Changes (All)' or 'SVN Changes'
  vim.fn.setqflist({}, 'r', { title = title, items = items })
  if #items > 0 then
    vim.cmd('copen')
  else
    vim.cmd('cclose')
    local message = include_unversioned and 'No SVN changes found' or 'No tracked SVN changes found'
    vim.notify(message, vim.log.levels.INFO)
  end
end

vim.api.nvim_create_user_command('SvnChanges', function()
  populate_svn_changes(false)
end, { desc = 'Populate quickfix with tracked svn status changes' })

vim.api.nvim_create_user_command('SvnChangesAll', function()
  populate_svn_changes(true)
end, { desc = 'Populate quickfix with all svn status changes' })

vim.keymap.set('n', '<leader>sc', '<cmd>SvnChanges<CR>', { desc = 'SVN changed files' })
vim.keymap.set('n', '<leader>sC', '<cmd>SvnChangesAll<CR>', { desc = 'SVN changed files (all)' })
vim.keymap.set('n', ']q', '<cmd>cnext<CR>', { desc = 'Quickfix next' })
vim.keymap.set('n', '[q', '<cmd>cprev<CR>', { desc = 'Quickfix prev' })

-- Gitsigns keymaps
vim.keymap.set("n", "]h", "<cmd>Gitsigns next_hunk<CR>", { desc = "Next hunk" })
vim.keymap.set("n", "[h", "<cmd>Gitsigns prev_hunk<CR>", { desc = "Prev hunk" })
vim.keymap.set("n", "<leader>hp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Preview hunk" })
vim.keymap.set("n", "<leader>hs", "<cmd>Gitsigns stage_hunk<CR>", { desc = "Stage hunk" })
vim.keymap.set("n", "<leader>hr", "<cmd>Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })

-- Java LSP (jdtls) — starts per-project with Lombok support
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'java',
  callback = function()
    local ok, jdtls = pcall(require, 'jdtls')
    if not ok then return end

    local mason_packages = vim.fn.stdpath('data') .. '/mason/packages'
    local jdtls_path = mason_packages .. '/jdtls'
    local launcher_jar = vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')

    if launcher_jar == '' then
      vim.notify('[jdtls] Not installed yet. Open :Mason and install jdtls.', vim.log.levels.WARN)
      return
    end

    local lombok_jar = jdtls_path .. '/lombok.jar'
    local java_home = '/opt/homebrew/Cellar/openjdk/25.0.2/libexec/openjdk.jdk/Contents/Home'
    local os_config = vim.fn.isdirectory(jdtls_path .. '/config_mac_arm64') == 1
      and 'config_mac_arm64' or 'config_mac'

    -- Separate workspace dir per project (jdtls requirement)
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
    local workspace_dir = vim.fn.stdpath('data') .. '/jdtls-workspace/' .. project_name

    local capabilities = vim.tbl_deep_extend(
      'force',
      vim.lsp.protocol.make_client_capabilities(),
      require('blink.cmp').get_lsp_capabilities()
    )

    local function on_attach(_, bufnr)
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition,     { desc = 'Go to definition',     buffer = bufnr })
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration,    { desc = 'Go to declaration',    buffer = bufnr })
      vim.keymap.set('n', 'gr', function()
        require('telescope.builtin').lsp_references({ include_declaration = true, include_current_line = true })
      end, { desc = 'Go to references (Telescope)', buffer = bufnr })
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = 'Go to implementation', buffer = bufnr })
      vim.keymap.set('n', 'K',  vim.lsp.buf.hover,          { desc = 'Hover',                buffer = bufnr })
      vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code action', buffer = bufnr })
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename',               buffer = bufnr })
      -- Java-specific: organize imports
      vim.keymap.set('n', '<leader>oi', jdtls.organize_imports, { desc = 'Organize imports', buffer = bufnr })
    end

    jdtls.start_or_attach({
      cmd = {
        java_home .. '/bin/java',
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.level=ALL',
        '-Xmx2g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens', 'java.base/java.util=ALL-UNNAMED',
        '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
        '-javaagent:' .. lombok_jar,
        '-jar', launcher_jar,
        '-configuration', jdtls_path .. '/' .. os_config,
        '-data', workspace_dir,
      },
      root_dir = jdtls.setup.find_root({ 'pom.xml', 'build.gradle', '.git' }),
      settings = {
        java = {
          configuration = {
            runtimes = {
              { name = 'JavaSE-1.8', path = java_home },
            },
          },
          maven = { downloadSources = true },
          referencesCodeLens = { enabled = true },
          implementationsCodeLens = { enabled = true },
        },
      },
      capabilities = capabilities,
      on_attach = on_attach,
    })
  end,
})
