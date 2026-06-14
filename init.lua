-- ========================================================================== --
--                               SETTINGS & OPTIONS                           --
-- ========================================================================== --

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Tabs & Indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Enable mouse support
vim.opt.mouse = 'a'

-- Sync clipboard between OS and Neovim ("yank should copy to clipboard")
vim.opt.clipboard = 'unnamedplus'

-- Set leader key to space
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- yank highlight

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- ========================================================================== --
--                               PLUGIN MANAGER                               --
-- ========================================================================== --

-- Bootstrap lazy.nvim
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

-- Setup plugins
  
require("lazy").setup({
  -- nvim-lspconfig still holds the library of server definitions!
  {
   'nvim-neo-tree/neo-tree.nvim',
    version = '*',

    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },

    lazy = false,

    keys = {
      {
        '\\',
        ':Neotree reveal<CR>',
        desc = 'NeoTree reveal',
        silent = true,
      },
    },

    opts = {
      default_component_configs = {
        git_status = {
          symbols = {
            added     = "+",
            modified  = "*",
            deleted   = "x",
            renamed   = "r",
            untracked = "?",
            ignored   = "!",
            unstaged  = "U",
            staged    = "S",
            conflict  = "C",
          },
        },
      },

      filesystem = {
        window = {
          mappings = {
            ['\\'] = 'close_window',
          },
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
  },

  -- Autocompletion engine
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
    },
  },

  -- Colorscheme
  { "rebelot/kanagawa.nvim", priority = 1000 },
  -- { "folke/tokyonight.nvim", priority = 1000 },
})

-- Set colorscheme
-- vim.cmd.colorscheme("tokyonight-night")
vim.cmd.colorscheme("kanagawa-dragon")

-- ========================================================================== --
--                               LSP & AUTOCOMPLETE                           --
-- ========================================================================== --

-- Setup Mason to manage external tooling binaries
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "gopls", "pyright", "clangd" },
})

-- Capabilities for autocompletion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- NEW API WAY: Define global configurations and enable them
-- This replaces the deprecated `require('lspconfig').setup()` framework
local servers = { "gopls", "pyright", "clangd" }

for _, server in ipairs(servers) do
  vim.lsp.config(server, {
    capabilities = capabilities,
  })
  vim.lsp.enable(server)
end

-- Setup Autocompletion menu
local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim-lsp' },
  }),
})

-- ========================================================================== --
--                               KEYMAPS                                      --
-- ========================================================================== --

-- Modern Neovim maps these cleanly using an Autocommand when an LSP attaches
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, vim.tbl_extend('force', opts, { desc = "Go to Definition" }))
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, vim.tbl_extend('force', opts, { desc = "Hover Documentation" }))
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, vim.tbl_extend('force', opts, { desc = "Rename Symbol" }))
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, vim.tbl_extend('force', opts, { desc = "Code Action" }))
    vim.keymap.set('n', '<Bslash>', ':NvimTreeToggle<CR>', { silent = true, desc = "Toggle File Tree" })
  end,
})
