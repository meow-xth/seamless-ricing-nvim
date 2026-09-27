-- NvChad v2.5 already ships the UIEnter/BufReadPost -> "User FilePost" ->
-- FileType pipeline in lua/nvchad/autocmds.lua.
--
-- This file previously re-implemented that same pipeline under a second
-- augroup ("NvFilePostFix"), which made "User FilePost" and "FileType" fire
-- TWICE per file. That loaded gitsigns / indent-blankline / nvim-lspconfig
-- twice, ran vim.treesitter.start() twice and re-ran every LSP FileType hook
-- on every buffer -- duplicated work, duplicated autocmds, and a large part of
-- the startup/render cost.
--
-- Everything needed is handled upstream, so this file only adds config that
-- NvChad does not provide.

local group = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Mark the UI as ready ourselves as a safety net (NvChad also does this on
-- UIEnter); keeping it here means file-based lazy plugins load on the very
-- first buffer even when a session is started with a file argument.
vim.api.nvim_create_autocmd("UIEnter", {
  group = group,
  callback = function()
    vim.g.ui_entered = true
  end,
})

-- Close scratch/quickfix-help style windows with <C-c> instead of :q noise.
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "checkhealth", "qf", "help", "lspinfo", "man", "notify" },
  callback = function(args)
    vim.bo[args.buf].bufhidden = "wipe"
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = args.buf, silent = true })
  end,
})
