-- Highlight overrides loaded AFTER UIEnter to avoid blocking startup
-- This file is sourced from chadrc.lua via autocmd

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

-- Treesitter highlight overrides (from chadrc)
local treesitter_overrides = {
  -- Variables
  ["@variable"] = { fg = "#c0caf5" },
  ["@variable.builtin"] = { fg = "#f7768e", bold = true },
  ["@variable.parameter"] = { fg = "#e0af68", italic = true },
  ["@variable.member"] = { fg = "#7dcfff" },

  -- Functions
  ["@function"] = { fg = "#7aa2f7", bold = true },
  ["@function.builtin"] = { fg = "#bb9af7", bold = true },
  ["@function.call"] = { fg = "#7aa2f7" },
  ["@function.method"] = { fg = "#7aa2f7", bold = true },
  ["@function.method.call"] = { fg = "#7aa2f7" },

  -- Types
  ["@type"] = { fg = "#2ac3de", bold = true },
  ["@type.builtin"] = { fg = "#2ac3de", bold = true, italic = true },
  ["@type.definition"] = { fg = "#2ac3de", bold = true },
  ["@type.qualifier"] = { fg = "#f7768e", italic = true },

  -- Constants
  ["@constant"] = { fg = "#ff9e64", bold = true },
  ["@constant.builtin"] = { fg = "#ff9e64", bold = true },
  ["@constant.macro"] = { fg = "#ff9e64" },

  -- Keywords
  ["@keyword"] = { fg = "#bb9af7", bold = true, italic = true },
  ["@keyword.function"] = { fg = "#bb9af7", bold = true },
  ["@keyword.operator"] = { fg = "#bb9af7", bold = true },
  ["@keyword.return"] = { fg = "#bb9af7", bold = true, italic = true },
  ["@keyword.conditional"] = { fg = "#bb9af7", bold = true, italic = true },
  ["@keyword.repeat"] = { fg = "#bb9af7", bold = true, italic = true },
  ["@keyword.import"] = { fg = "#bb9af7", italic = true },

  -- Operators
  ["@operator"] = { fg = "#89ddff", bold = true },

  -- Strings
  ["@string"] = { fg = "#9ece6a" },
  ["@string.escape"] = { fg = "#f7768e", bold = true },
  ["@string.regex"] = { fg = "#b4f9f8" },

  -- Numbers
  ["@number"] = { fg = "#ff9e64" },
  ["@number.float"] = { fg = "#ff9e64" },

  -- Properties/Fields
  ["@property"] = { fg = "#7dcfff" },
  ["@field"] = { fg = "#7dcfff" },

  -- Parameters
  ["@parameter"] = { fg = "#e0af68", italic = true },

  -- Namespaces/Modules
  ["@module"] = { fg = "#7aa2f7", italic = true },
  ["@namespace"] = { fg = "#7aa2f7", italic = true },

  -- Attributes/Annotations
  ["@attribute"] = { fg = "#bb9af7", italic = true },
  ["@decorator"] = { fg = "#bb9af7", italic = true },

  -- Preprocessor
  ["@preproc"] = { fg = "#f7768e" },
  ["@define"] = { fg = "#f7768e" },

  -- Tags (JSX/HTML)
  ["@tag"] = { fg = "#f7768e" },
  ["@tag.attribute"] = { fg = "#7dcfff" },
  ["@tag.delimiter"] = { fg = "#545c7e" },

  -- LSP semantic tokens
  ["@lsp.type.variable"] = { link = "@variable" },
  ["@lsp.type.function"] = { link = "@function" },
  ["@lsp.type.method"] = { link = "@function.method" },
  ["@lsp.type.class"] = { link = "@type" },
  ["@lsp.type.struct"] = { link = "@type" },
  ["@lsp.type.interface"] = { link = "@type" },
  ["@lsp.type.enum"] = { link = "@type" },
  ["@lsp.type.enumMember"] = { link = "@constant" },
  ["@lsp.type.parameter"] = { link = "@parameter" },
  ["@lsp.type.property"] = { link = "@property" },
  ["@lsp.type.namespace"] = { link = "@namespace" },
  ["@lsp.type.typeParameter"] = { link = "@type.definition" },
  ["@lsp.type.macro"] = { link = "@constant.macro" },
  ["@lsp.mod.readonly"] = { italic = true },
  ["@lsp.mod.static"] = { bold = true },
  ["@lsp.mod.declaration"] = { bold = true },
  ["@lsp.mod.definition"] = { bold = true },
}

-- Comment/italic
pcall(hl, 0, "Comment", { italic = true })
pcall(hl, 0, "@comment", { italic = true })

-- Apply treesitter overrides
for group, opts in pairs(treesitter_overrides) do
  pcall(hl, 0, group, opts)
end