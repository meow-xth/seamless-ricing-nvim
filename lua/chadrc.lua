-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "bearded-arc",
}

M.nvdash = { load_on_startup = false }
M.ui = {
  telescope = { style = "bordered" }, -- konsisten dgn float rounded
  tabufline = {
    lazyload = false
  },
  statusline = {
    theme = "minimal",
    separator_style = "round",
    -- default NvChad + "run" disisipkan sebelum diagnostics
    order = { "mode", "file", "git", "%=", "lsp_msg", "%=", "run", "perf", "diagnostics", "lsp", "cwd", "cursor" },
    modules = {
      mode = function()
        if vim.api.nvim_get_current_win() ~= vim.g.statusline_winid then
          return ""
        end

        local m = vim.api.nvim_get_mode().mode
        local txt, hl

        if vim.bo.buftype == "terminal" then
          if m == "t" then
            txt, hl = "INSERT", "Terminal"
          else
            txt, hl = "NORMAL", "NTerminal"
          end
        else
          local modes = require("nvchad.stl.utils").modes
          local entry = modes[m]
          if not entry then
            return ""
          end
          txt, hl = entry[1], entry[2]
        end

        return ("%%#St_%sModeSep#\u{e0b6}%%#St_%sMode# \u{e6a6}%%#St_%sModeText# %s %%#St_sep_r#\u{e0b4} %%#ST_EmptySpace#"):format(hl, hl, hl, txt)
      end,

      -- hasil <leader>r terakhir: kosong kalau belum pernah run
      run = function()
        local ok, runner = pcall(require, "configs.run")
        local last = ok and runner.last or nil
        if not last then
          return ""
        end
        if last.code == 0 then
          return ("%%#DiagnosticOk# ✓ %s "):format(last.secs)
        end
        return ("%%#DiagnosticError# ✗ exit %d "):format(last.code)
      end,

      -- performance: startup time + plugin count (cached, updated on events)
      perf = function()
        if not vim.g._perf_cached then
          local ok, perf = pcall(require, "configs.performance")
          if not ok then
            return ""
          end
          local time = perf.get_startup_time()
          local lazy_stats = perf.get_lazy_stats()
          local plugin_str = lazy_stats and string.format("%d/%d", lazy_stats.loaded, lazy_stats.count) or "?"
          vim.g._perf_cached = string.format("%%#St_EmptySpace#⚡ %dms %%#St_sep_l#\u{e0b4}%%#St_EmptySpace#📦 %s ", time, plugin_str)
        end
        return vim.g._perf_cached
      end,
    },
  },
}

-- default global utk semua floating terminal (runner <leader>r, <A-i>, ...).
-- float_opts per-panggilan di-merge di atas ini.
M.term = {
  float = {
    relative = "editor",
    row = 0.16,
    col = 0.14,
    width = 0.72,
    height = 0.65,
    border = "rounded",
  },
}

return M
