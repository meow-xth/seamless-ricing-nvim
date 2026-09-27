return {
  defaults = { lazy = true },
  install = { colorscheme = { "nvchad" } },

  ui = {
    icons = {
      ft = "",
      lazy = "󰂠 ",
      loaded = "",
      not_loaded = "",
    },
  },

  checker = { enabled = true, notify = false },
  change_detection = { enabled = true, notify = false },

  performance = {
    -- Only real, standalone plugin scripts belong here. Entries such as
    -- "syntax", "ftplugin", "optwin" or "compiler" are runtime *directories*,
    -- not plugins; listing them made the intent unclear while doing nothing
    -- useful. The set below is the documented lazy.nvim list.
    rtp = {
      disabled_plugins = {
        "2html_plugin",
        "bugreport",
        "getscript",
        "getscriptPlugin",
        "gzip",
        "logipat",
        "matchit",
        "netrw",
        "netrwFileHandlers",
        "netrwPlugin",
        "netrwSettings",
        "rplugin",
        "tar",
        "tarPlugin",
        "tohtml",
        "tutor",
        "vimball",
        "vimballPlugin",
        "zip",
        "zipPlugin",
      },
    },

    cache = {
      enabled = true,
      path = vim.fn.stdpath "cache" .. "/lazy.lua",
    },
  },
}
