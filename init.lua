vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- Load the cached base46 highlight overrides.
-- These files only exist after the nvchad/base46 build step has run once. On a
-- brand new machine (or right after wiping stdpath("data")) a bare dofile()
-- throws and aborts the whole startup, so probe first and fall back to NvChad's
-- own theme loader.
local base46_ok = pcall(function()
  dofile(vim.g.base46_cache .. "defaults")
  dofile(vim.g.base46_cache .. "statusline")
end)

if not base46_ok then
  require("base46").load_all_highlights()
end

require "options"
require "autocmds"
require("configs.ui").setup()
require("configs.performance").mark "configs_loaded"

vim.schedule(function()
  require "mappings"
end)
