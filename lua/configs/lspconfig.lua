require("nvchad.configs.lspconfig").defaults()

-- ===== Signature Help =====
-- (vim.lsp.with is deprecated on Nvim 0.11+, so wrap the handler directly)
local default_sig_help = vim.lsp.handlers["textDocument/signatureHelp"]
vim.lsp.handlers["textDocument/signatureHelp"] = function(err, result, ctx, config)
  config = vim.tbl_extend("force", {
    border = "rounded",
    focusable = false,
    close_events = { "CursorMoved", "BufHidden", "InsertCharPre" },
    max_height = 15,
    max_width = 80,
    title = " Signature ",
    title_pos = "center",
  }, config or {})
  return default_sig_help(err, result, ctx, config)
end

-- ===== Smart Diagnostics =====
-- Goal: all errors visible as inline text, except on the line the cursor is
-- currently on -- that line keeps its underline/sign only, so a wall of text
-- does not follow you around while you fix the code in front of you.
--
-- This used to be ~60 lines of hand-rolled Lua that called
-- vim.diagnostic.show() on a private namespace on every CursorMoved. That was
-- wrong twice over:
--   * vim.diagnostic.show() reads buffer lines per diagnostic, so a stale
--     diagnostic whose lnum sat past EOF raised
--     "Index out of bounds" (nvim_buf_get_lines) on Neovim 0.12.
--   * it re-rendered every diagnostic in Lua on every single cursor move.
--
-- Neovim 0.12 ships this exact behaviour as `virtual_text.current_line`, and
-- its renderer already skips lines past the end of the buffer -- so the crash
-- cannot happen and the whole autocmd machinery is unnecessary.
local SEVERITY_ICON = {
  [vim.diagnostic.severity.ERROR] = " ",
  [vim.diagnostic.severity.WARN] = " ",
  [vim.diagnostic.severity.INFO] = " ",
  [vim.diagnostic.severity.HINT] = " ",
}

local function diag_prefix(diag)
  return SEVERITY_ICON[diag.severity] or "• "
end

vim.diagnostic.config {
  virtual_text = {
    -- false => show every diagnostic EXCEPT the ones on the cursor's line
    current_line = false,
    spacing = 2,
    source = "if_many",
    prefix = diag_prefix,
  },
  float = {
    border = "rounded",
    header = " Diagnostics ",
    prefix = diag_prefix,
    source = "always",
    severity_sort = true,
    focusable = true,
    max_width = 90,
    max_height = 20,
  },
  update_in_insert = false,
  underline = true,
  virtual_lines = false,
  signs = true,
}

-- Make sure a long session picks up config/theme changes without a restart.
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("SmartDiagnosticsReset", { clear = true }),
  callback = function()
    pcall(vim.diagnostic.config, { virtual_text = {
      current_line = false,
      spacing = 2,
      source = "if_many",
      prefix = diag_prefix,
    } })
  end,
})

-- ===== Organize includes on save =====
-- clangd only offers "add missing include" at a cursor position (that part is
-- handled automatically by nvim-cmp via additionalTextEdits). What it can do
-- globally is organizeIncludes: sort / dedupe / drop unused includes.
-- Bounded synchronous wait so the result is on disk before the write finishes.
local function organize_imports(bufnr)
  local client = vim.lsp.get_clients { name = "clangd", bufnr = bufnr }[1]
  if not client or not client:supports_method "textDocument/codeAction" then
    return
  end

  local result
  local params = vim.lsp.util.make_given_range_params(nil, nil, bufnr, "utf-16")
  params.context = { diagnostics = {}, only = { "source.organizeImports" } }

  pcall(function()
    client:request("textDocument/codeAction", params, function(_, res)
      result = res
    end, bufnr)
  end)

  if not vim.wait(400, function()
    return result ~= nil
  end, 10) then
    return
  end

  local actions = result or {}
  for _, action in ipairs(actions) do
    if action.edit then
      local applied = vim.lsp.util.apply_workspace_edit(action.edit, "utf-16", bufnr)
      if applied then
        return
      end
    end
  end
end

local function on_attach(client, bufnr)
  if client.server_capabilities.signatureHelpProvider and client.name ~= "asm_lsp" then
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { buffer = bufnr, desc = "LSP Signature Help" })
    vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, { buffer = bufnr, desc = "LSP Signature Help" })
  end

  if client.name == "clangd" then
    -- Do NOT also register a BufWritePre here: conform.nvim already owns
    -- BufWritePre for formatting, and two async writers race each other.
    -- Instead chain them in the autocmd below.
    vim.b[bufnr].clangd_organize_imports = true
  end
end

-- ===== Server configs =====
vim.lsp.config("clangd", {
  on_attach = on_attach,
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--fallback-style=LLVM",
    "--all-scopes-completion",
    "--cross-file-rename",
    "--pch-storage=memory",
    "-j=4",
  },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  -- root_markers (not a root_dir function) so vim.lsp.enable() resolves the
  -- project root to a real string; a raw root_dir function here used to leak
  -- through as client.root_dir == <function>.
  root_markers = { "compile_commands.json", "compile_flags.txt", ".clangd", ".git" },
})

local venv = require "configs.venv"

vim.lsp.config("pyright", {
  on_attach = on_attach,
  root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
  settings = {
    python = {
      pythonPath = venv.find_python(),
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
        autoImportCompletions = true,
        diagnosticSeverityOverrides = {
          reportUnusedImport = "information",
          reportUnusedVariable = "information",
          reportMissingImports = "error",
          reportMissingTypeStub = "information",
        },
      },
    },
  },
})

vim.lsp.config("cmake", { on_attach = on_attach, root_markers = { "CMakeLists.txt", ".git" } })
vim.lsp.config("html", { on_attach = on_attach })
vim.lsp.config("cssls", { on_attach = on_attach })

vim.lsp.config("asm_lsp", {
  on_attach = on_attach,
  filetypes = { "asm", "s", "S", "nasm" },
  root_markers = { ".git", "Makefile", "makefile", "CMakeLists.txt" },
})

-- vim.lsp.enable() installs the FileType autocmd that attaches each server and
-- resolves root_dir/root_markers correctly. The old hand-rolled FileType
-- starter that called vim.lsp.start(vim.lsp.config[x]) is gone: it bypassed
-- root resolution and double-started servers.
vim.lsp.enable { "html", "cssls", "clangd", "pyright", "cmake", "asm_lsp" }

-- ===== Save pipeline (single owner: organize includes -> format) =====
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("LspSavePipeline", { clear = true }),
  callback = function(args)
    if vim.b[args.buf].clangd_organize_imports then
      pcall(organize_imports, args.buf)
    end
  end,
})

-- Re-assert pyright's interpreter when the buffer belongs to a different venv
local function sync_pyright_python_path(bufnr, attempts)
  attempts = attempts or 0
  if attempts > 8 then
    return
  end
  local client = vim.lsp.get_clients { name = "pyright", bufnr = bufnr }[1]
  if not client then
    vim.defer_fn(function()
      sync_pyright_python_path(bufnr, attempts + 1)
    end, 300)
    return
  end
  local path = venv.find_python(bufnr)
  if client.settings.python.pythonPath ~= path then
    local new_settings = vim.tbl_deep_extend("force", client.settings, {
      python = { pythonPath = path },
    })
    client.settings = new_settings
    client:notify("workspace/didChangeConfiguration", { settings = new_settings })
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspAttachSync", { clear = true }),
  callback = function(args)
    if vim.lsp.get_clients { name = "pyright", bufnr = args.buf }[1] then
      vim.defer_fn(function()
        sync_pyright_python_path(args.buf, 0)
      end, 200)
    end
  end,
})
