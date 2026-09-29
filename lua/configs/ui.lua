-- Extra UI polish using only core Neovim -- no new plugins.
--
-- NOTE: no dashboard here on purpose. NvChad already opens its own dashboard
-- (nvchad/ui's nvdash) on an empty start, so an extra one would fight it.
local M = {}

local AUGROUP = "AbideUI"

-- ===== 1. LSP progress feedback =====
-- NvChad renders its own statusline, so instead of fighting it we surface
-- clangd/pyright indexing through short notifications. Fires once per client
-- per phase, so it stays quiet during normal editing.
local progress_seen = {}

local function on_lsp_progress(args)
  local client = vim.lsp.get_clients({ bufnr = args.buf })[1]
  if not client then
    return
  end

  local result = args.data and args.data.result
  if not result then
    return
  end

  local kind = result.kind
  local token = client.id .. ":" .. tostring(kind)
  if progress_seen[token] then
    return
  end
  progress_seen[token] = true

  local msg = ({
    begin = "starting",
    report = "indexing",
    ["end"] = "ready",
  })[kind]
  if not msg then
    return
  end

  local pct = result.percentage and (" (" .. result.percentage .. "%)") or ""
  vim.notify(
    ("%s: %s%s"):format(client.name, msg, pct),
    kind == "end" and vim.log.levels.INFO or vim.log.levels.DEBUG,
    { title = "LSP" }
  )
end

-- ===== 2. Highlight-group polish =====
-- Dim split separators and search matches so they read as chrome, not content.
local function apply_highlights()
  local hl = vim.api.nvim_set_hl

  -- Softer split separator: chrome, not content
  pcall(hl, 0, "WinSeparator", { fg = "#3b4261", default = true })

  -- Search states: make the active match unmistakable while typing
  pcall(hl, 0, "CurSearch", { bg = "#f7768e", fg = "#1a1b26", default = true })
  pcall(hl, 0, "IncSearch", { bg = "#ff9e64", fg = "#1a1b26", default = true })
  pcall(hl, 0, "Search", { bg = "#414868", default = true })

  pcall(hl, 0, "Visual", { bg = "#414868", default = true })
  pcall(hl, 0, "SignColumn", { bg = "#1a1b26", default = true })
  pcall(vim.api.nvim_set_hl, 0, "CursorLineSign", { bg = "#1a1b26", default = true })

  -- Diagnostics: use the same severity colours as the inline virtual text
  pcall(vim.api.nvim_set_hl, 0, "DiagnosticUnnecessary", { fg = "#565f89", default = true })
  pcall(vim.api.nvim_set_hl, 0, "DiagnosticHint", { fg = "#7dcfff", default = true })
  pcall(vim.api.nvim_set_hl, 0, "DiagnosticInfo", { fg = "#7dcfff", default = true })
end

-- ===== 3. nvim-notify: minimal, load on demand =====
local function setup_notify()
  local notify = require "notify"
  notify.setup {
    render = "minimal",
    stages = "static",
    timeout = 2000,
    top_down = false,
    max_width = 60,
    max_height = 10,
    background_colour = "#1a1b26",
  }
  vim.notify = notify
end

function M.setup()
  local group = vim.api.nvim_create_augroup(AUGROUP, { clear = true })

  vim.api.nvim_create_autocmd("LspProgress", {
    group = group,
    callback = on_lsp_progress,
  })

  apply_highlights()

  -- Lazy-load nvim-notify on first vim.notify call
  vim.notify = function(msg, level, opts_)
    setup_notify()
    return vim.notify(msg, level, opts_)
  end
end

return M
