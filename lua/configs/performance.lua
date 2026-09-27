-- Performance monitoring for Neovim startup and runtime
-- Add to statusline or call :PerfReport

local M = {}

M.start_time = vim.uv.hrtime()
M.marks = {}

function M.mark(name)
  local now = vim.uv.hrtime()
  M.marks[name] = {
    elapsed_ms = (now - M.start_time) / 1e6,
    timestamp = now,
  }
end

function M.get_startup_time()
  return (vim.uv.hrtime() - M.start_time) / 1e6
end

function M.get_lazy_stats()
  local ok, lazy = pcall(require, "lazy")
  if not ok then
    return nil
  end
  local stats = lazy.stats()
  return {
    loaded = stats.loaded,
    count = stats.count,
    startup_time = stats.startuptime,
  }
end

function M.report()
  local lines = { "=== Neovim Performance Report ===" }
  table.insert(lines, string.format("Startup time: %.2fms", M.get_startup_time()))

  local lazy_stats = M.get_lazy_stats()
  if lazy_stats then
    table.insert(lines, string.format("Plugins loaded: %d/%d", lazy_stats.loaded, lazy_stats.count))
    if lazy_stats.startup_time then
      table.insert(lines, string.format("Lazy.nvim startup: %.2fms", lazy_stats.startup_time))
    end
  end

  if #M.marks > 0 then
    table.insert(lines, "\nCustom marks:")
    for name, data in pairs(M.marks) do
      table.insert(lines, string.format("  %s: %.2fms", name, data.elapsed_ms))
    end
  end

  -- Memory usage (approximate)
  local mem = collectgarbage("count")
  table.insert(lines, string.format("\nMemory: %.2f KB", mem))

  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "Performance" })
end

function M.statusline()
  local time = M.get_startup_time()
  local lazy_stats = M.get_lazy_stats()
  local plugin_str = lazy_stats and string.format("%d/%d", lazy_stats.loaded, lazy_stats.count) or "?"
  return string.format("⚡ %.0fms | 📦 %s", time, plugin_str)
end

-- Auto-mark key events
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  callback = function()
    M.mark("LazyDone")
  end,
})

vim.api.nvim_create_autocmd("UIEnter", {
  callback = function()
    M.mark("UIEnter")
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    M.mark("VimEnter")
  end,
})

vim.api.nvim_create_user_command("PerfReport", function()
  M.report()
end, { desc = "Show performance report" })

vim.api.nvim_create_user_command("PerfStartupTime", function()
  vim.notify(string.format("Startup: %.2fms", M.get_startup_time()), vim.log.levels.INFO, { title = "Performance" })
end, { desc = "Show startup time" })

return M