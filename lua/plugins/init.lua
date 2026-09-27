return {
  -- ===== Formatting =====
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  -- ===== LSP =====
  -- Lazy-load on first buffer. The config sets up diagnostics, handlers,
  -- server configs and enables them -- all of which only need to exist when
  -- a file is actually opened. NvChad's default spec uses "User FilePost";
  -- BufReadPre is earlier and ensures zero startup cost.
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "wakatime/vim-wakatime",
    lazy = false,
    config = function() end,
  },

  -- NOTE: nvim-cmp is owned by NvChad (event = "InsertEnter"). This spec only
  -- *adds* to it: configs/cmp.lua receives NvChad's config as its second
  -- argument and returns the merged result, so lazy.nvim still performs
  -- exactly one cmp.setup(). A competing cmp.setup() used to clobber NvChad's
  -- mappings and silently break clangd's auto-import.
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    opts = function(_, ret)
      return require "configs.cmp"(_, ret)
    end,
  },

  -- ===== Treesitter =====
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "cpp",
        "c",
        "cmake",
        "python",
        "toml",
        "json",
        "yaml",
        "markdown",
        "asm",
        "nasm",
      },
    },
  },

  -- ===== Chunk highlights (animated scope borders) =====
  -- NvChad already loads indent-blankline on "User FilePost" for indent guides.
  -- hlchunk's own indent layer would draw a *second* set of indent bars on top
  -- of it, so it stays off here.
  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("hlchunk").setup {
        chunk = {
          enable = true,
          style = { { fg = "#806d9c" } },
          use_treesitter = true,
          chars = {
            horizontal_line = "─",
            vertical_line = "│",
            left_top = "╭",
            left_bottom = "╰",
            right_arrow = "->",
          },
          duration = 200,
          delay = 100,
        },
        indent = { enable = false },
        line_num = { enable = true },
        blank = { enable = false },
      }
    end,
  },

  -- ===== Debugging =====
  -- All DAP plugins are lazy: they cost startup time but are only needed once
  -- a session actually starts debugging.
  {
    "mfussenegger/nvim-dap",
    cmd = { "DapContinue", "DapToggleBreakpoint", "DapToggleRepl", "DapEval" },
    keys = {
      { "<leader>db", "<cmd>DapToggleBreakpoint<cr>", desc = "Toggle breakpoint" },
      { "<leader>dc", "<cmd>DapContinue<cr>", desc = "Debug/continue" },
      { "<leader>dr", "<cmd>DapToggleRepl<cr>", desc = "DAP REPL" },
      { "<leader>dso", "<cmd>DapStepOver<cr>", desc = "Step over" },
      { "<leader>dsi", "<cmd>DapStepInto<cr>", desc = "Step into" },
    },
    config = function()
      require "configs.dap"
    end,
  },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    cmd = "DapUIOpen",
    keys = { { "<leader>dui", "<cmd>DapUIToggle<cr>", desc = "Toggle DAP UI" } },
    config = function()
      require("dapui").setup()
    end,
  },

  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("nvim-dap-virtual-text").setup()
    end,
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "mason-org/mason.nvim", "mfussenegger/nvim-dap" },
    opts = {
      ensure_installed = { "codelldb", "debugpy" },
      automatic_installation = true,
    },
  },

  -- ===== Tools =====
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- lazy: only needed when the user runs :MasonInstall
    cmd = "MasonInstall",
    opts = {
      ensure_installed = {
        "clangd",
        "pyright",
        "html-lsp",
        "css-lsp",
        "cmake-language-server",
        "clang-format",
        "ruff",
        "codelldb",
        "debugpy",
        "stylua",
        "asm-lsp",
        "asmfmt",
      },
      auto_update = false,
      run_on_start = false,
      debounce_hours = 24,
    },
  },

  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    opts = {},
  },

  {
    "chikko80/error-lens.nvim",
    enabled = false, -- replaced by the smart diagnostic handler
  },

  {
    "ray-x/lsp_signature.nvim",
    event = "LspAttach",
    opts = {
      bind = false, -- own <C-k> mapping is set in configs/lspconfig.lua
      handler_opts = { border = "rounded" },
      hint_enable = true,
      hint_prefix = "󰊕 ",
      hint_scheme = "Comment",
      hi_parameter = "LspSignatureActiveParameter",
      max_height = 15,
      max_width = 80,
      floating_window = true,
      floating_window_above_cur_line = true,
      fix_pos = false,
      always_trigger = false,
      extra_trigger_chars = { "(", ",", "=" },
      zindex = 200,
      padding = " ",
      transparency = 10,
      shadow_blend = 36,
      shadow_guibg = "Black",
      timer_interval = 200,
      toggle_key = "<C-k>",
      select_signature_key = "<C-n>",
      move_cursor_key = "<C-p>",
    },
    config = function(_, opts)
      local ft = vim.bo.filetype
      if ft == "asm" or ft == "nasm" or ft == "s" or ft == "S" then
        return
      end
      require("lsp_signature").setup(opts)
    end,
  },

  {
    -- notifikasi minimal & tenang: tanpa animasi geser, render ramping
    -- load on UIEnter (after UI ready) so vim.notify is available early
    -- but doesn't block startup; wrapped to load on first notify call
    "rcarriga/nvim-notify",
    event = "UIEnter",
    priority = 900,
    opts = {
      render = "minimal",
      stages = "static",
      timeout = 2000,
      top_down = false,
      max_width = 60,
      max_height = 10,
      background_colour = "#1a1b26",
    },
    config = function(_, opts)
      local notify = require "notify"
      notify.setup(opts)
      vim.notify = function(msg, level, opts_)
        -- lazy-load on first call if not ready
        if vim.notify == notify then
          return notify(msg, level, opts_)
        end
        -- fallback: load notify now
        notify.setup(opts)
        vim.notify = notify
        return notify(msg, level, opts_)
      end
    end,
  },
}
