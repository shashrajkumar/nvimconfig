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

-- Enable mouse support (just in case)
vim.opt.mouse = 'a'

-- Sync clipboard between OS and Neovim
-- This fulfills: "yank should copy to clipboard"
vim.opt.clipboard = 'unnamedplus'

-- Set leader key to space
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- ========================================================================== --
--                               PLUGIN MANAGER                               --
-- ========================================================================== --

-- Bootstrap lazy.nvim (downloads it automatically if missing)
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
  -- LSP Configuration & Plugins
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
  },

  -- Optional: Autocompletion engine (highly recommended for LSP)
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
    },
  },

  -- Optional: A nice colorscheme so it looks good out of the box
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
})

-- Set colorscheme
vim.cmd.colorscheme("catppuccin-mocha")

-- ========================================================================== --
--                               LSP & AUTOCOMPLETE                           --
-- ========================================================================== --

-- Setup Mason to manage external tooling
require("mason").setup()

-- Ensure the language servers for Go, Python, and C are installed
-- gopls -> Go
-- pyright -> Python
-- clangd -> C/C++
require("mason-lspconfig").setup({
  ensure_installed = { "gopls", "pyright", "clangd" },
})

-- Capabilities for autocompletion
local capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_lsp = require("cmp_nvim_lsp")
capabilities = cmp_lsp.default_capabilities(capabilities)

-- Setup individual language servers
local lspconfig = require("lspconfig")

lspconfig.gopls.setup({ capabilities = capabilities })
lspconfig.pyright.setup({ capabilities = capabilities })
lspconfig.clangd.setup({ capabilities = capabilities })

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
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept completion
  }),
  sources = cmp.config.sources({
    { name = 'nvim-lsp' },
  }),
})

-- ========================================================================== --
--                               KEYMAPS                                      --
-- ========================================================================== --

-- Global LSP Keybindings (Press these when your cursor is on a variable/function)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "Go to Definition" })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = "Hover Documentation" })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = "Rename Symbol" })
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = "Code Action" })
