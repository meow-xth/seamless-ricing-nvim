local dap = require "dap"

-- dapui.setup() is owned by the nvim-dap-ui plugin spec. It must not run here
-- too, otherwise nvim-dap-ui is configured twice and its listeners/layouts get
-- built on top of each other. Require it lazily inside the listeners instead.

dap.listeners.after.event_initialized["abide_dapui"] = function()
  require("dapui").open()
end
dap.listeners.before.event_terminated["abide_dapui"] = function()
  require("dapui").close()
end
dap.listeners.before.event_exited["abide_dapui"] = function()
  require("dapui").close()
end

-- Build a debug target from what the user just ran, falling back to prompting.
local function pick_program()
  local candidates = {
    vim.fn.getcwd() .. "/build/" .. vim.fn.fnamemodify(vim.fn.expand "%:t:r", ""),
    vim.fn.getcwd() .. "/a.out",
    vim.fn.getcwd() .. "/" .. vim.fn.fnamemodify(vim.fn.expand "%:t:r", ""),
  }
  for _, c in ipairs(candidates) do
    if vim.fn.filereadable(c) == 1 then
      return c
    end
  end
  return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
end

dap.adapters.codelldb = function(callback)
  local mason_packages = vim.fn.stdpath "data" .. "/mason/packages"
  local liblldb = mason_packages .. "/codelldb/extension/lldb/lib/liblldb.so"
  if vim.fn.filereadable(liblldb) == 0 then
    liblldb = vim.fn.exepath "lldb"
  end
  callback {
    type = "server",
    port = "${port}",
    executable = {
      command = vim.fn.exepath "codelldb",
      args = {
        "--liblldb", liblldb,
        "--port", "${port}",
      },
    },
  }
end

local cpp_configs = {
  {
    name = "Launch file (auto-detect)",
    type = "codelldb",
    request = "launch",
    program = pick_program,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
    args = {},
  },
  {
    name = "Attach to process",
    type = "codelldb",
    request = "attach",
    pid = require("dap.utils").pick_process,
    cwd = "${workspaceFolder}",
  },
}

dap.configurations.cpp = cpp_configs
dap.configurations.c = cpp_configs
dap.configurations.rust = cpp_configs

dap.adapters.python = {
  type = "executable",
  command = vim.fn.exepath "debugpy-adapter",
}

dap.configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "Launch file",
    program = "${file}",
    pythonPath = function()
      return require("configs.venv").find_python(0)
    end,
  },
  {
    type = "python",
    request = "launch",
    name = "Launch with arguments",
    program = "${file}",
    args = function()
      return vim.split(vim.fn.input "Arguments: ", " ")
    end,
    pythonPath = function()
      return require("configs.venv").find_python(0)
    end,
  },
  {
    type = "python",
    request = "attach",
    name = "Attach to process",
    connect = { host = "127.0.0.1", port = 5678 },
  },
}

for name, hl in pairs {
  DapBreakpoint = "DapBreakpoint",
  DapBreakpointCondition = "DapBreakpointCondition",
  DapLogPoint = "DapLogPoint",
  DapStopped = "DapStopped",
  DapBreakpointRejected = "DapBreakpointRejected",
} do
  pcall(vim.fn.sign_define, name, { text = "●", texthl = hl, linehl = "", numhl = "" })
end
