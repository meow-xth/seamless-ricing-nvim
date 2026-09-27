require "nvchad.mappings"

local map = vim.keymap.set

-- ===== Basics =====
map("n", ";", ":", { desc = "CMD enter command mode" })
map("n", "<C-h>", "<C-w>h", { desc = "Go left" })
map("n", "<C-j>", "<C-w>j", { desc = "Go down" })
map("n", "<C-k>", "<C-w>k", { desc = "Go up" })
map("n", "<C-l>", "<C-w>l", { desc = "Go right" })
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Write file" })
map({ "n", "i", "v" }, "<C-s>", "<cmd>write<cr>", { desc = "Write file" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Non-blocking <Esc> from insert mode: only leaves insert mode when "j" is not
-- followed by another "k" within `timeout`. A plain `map("i", "jk", "<Esc>")`
-- swallows the two characters even when you meant to type them.
local jk_pending = false
map("i", "j", function()
  if jk_pending then
    jk_pending = false
    return "jk"
  end
  jk_pending = true
  vim.defer_fn(function()
    jk_pending = false
  end, 250)
  return "j"
end, { desc = "jk to escape (non-blocking)" })
map("i", "<C-[>", "<Esc>", { desc = "Escape insert mode" })
map("i", "<C-c>", "<Esc>", { desc = "Abort insert mode" })

-- ===== LSP =====
-- Neovim 0.12 renamed the [c / ]c family to [a / ]a; keep the old keys working.
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
map("n", "<leader>D", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
-- NOTE: `vim.diagnostic.jump(count, float = true)` is a Lua syntax error --
-- the options table has to be passed explicitly.
local function diag_jump(count)
  vim.diagnostic.jump(count, { float = true })
end
map("n", "[a", function()
  diag_jump(-1)
end, { desc = "Previous diagnostic" })
map("n", "]a", function()
  diag_jump(1)
end, { desc = "Next diagnostic" })
map("n", "[d", function()
  diag_jump(-1)
end, { desc = "Previous diagnostic" })
map("n", "]d", function()
  diag_jump(1)
end, { desc = "Next diagnostic" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>ra", function()
  require "nvchad.lsp.renamer"
end, { desc = "NvRenamer" })
map("n", "<leader>fm", function()
  require("conform").format { async = true, lsp_format = "first" }
end, { desc = "Format buffer" })
map("n", "<leader>fmr", function()
  require("conform").format { async = true, lsp_format = "first", range = {
    range = { vim.api.nvim_win_get_cursor(0)[1] - 1, 0 },
    end_range = { vim.api.nvim_win_get_cursor(0)[1], 0 },
  } }
end, { desc = "Format range" })
map("n", "gl", vim.lsp.buf.document_symbol, { desc = "Document symbols" })
-- NOTE: vim.lsp.buf.codelens / vim.lsp.buf.inlay_hint were removed in
-- Neovim 0.12; the entry points are now vim.lsp.codelens and
-- vim.lsp.inlay_hint, and they take an action argument.
map("n", "<leader>cl", function()
  vim.lsp.codelens(vim.lsp.codelens.is_enabled() and "disable" or "enable")
end, { desc = "Toggle code lens" })
map("n", "<leader>iL", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(), { bufnr = 0 })
end, { desc = "Toggle inlay hints" })

-- ===== Diagnostics =====
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostics" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- ===== Trouble =====
map("n", "<leader>tx", function()
  require("trouble").toggle "diagnostics"
end, { desc = "All diagnostics (trouble)" })
map("n", "<leader>tX", function()
  require("trouble").toggle "diagnostics" { filter = { severity = vim.diagnostic.severity.ERROR } }
end, { desc = "Errors only (trouble)" })
map("n", "<leader>tf", function()
  require("trouble").toggle { filter = { filetype = vim.bo.filetype } }
end, { desc = "File diagnostics (trouble)" })

-- ===== Terminal =====
map("n", "<leader>h", function()
  require("nvchad.term").new { pos = "sp" }
end, { desc = "New horizontal terminal" })
map("n", "<leader>v", function()
  require("nvchad.term").new { pos = "vsp" }
end, { desc = "New vertical terminal" })
map("t", "<C-x>", "<C-\\><C-N>", { desc = "Terminal escape to normal mode" })
map({ "n", "t" }, "<A-h>", function()
  require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
end, { desc = "Toggle horizontal terminal" })
map({ "n", "t" }, "<A-v>", function()
  require("nvchad.term").toggle { pos = "vsp", id = "vtoggleTerm" }
end, { desc = "Toggle vertical terminal" })
map({ "n", "t" }, "<A-i>", function()
  require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
end, { desc = "Toggle floating terminal" })

-- ===== Run =====
map("n", "<leader>r", function()
  require("configs.run").run()
end, { desc = "Run current file (smart)" })
