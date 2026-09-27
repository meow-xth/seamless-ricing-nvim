-- Extra cmp settings, layered ON TOP of the nvim-cmp config NvChad already owns.
--
-- NvChad v2.5 wires nvim-cmp on InsertEnter via
--   opts = function() return require "nvchad.configs.cmp" end
--
-- lazy.nvim merges duplicate `opts` like this (Spec:merge):
--   ret = values(root, ret) or ret
-- i.e. the accumulated config is passed IN and the function's RETURN value
-- replaces it. So this must return the merged table and must NOT call
-- cmp.setup() itself -- doing that would be immediately overwritten by the
-- cmp.setup() lazy.nvim performs afterwards, which is exactly what silently
-- dropped these settings (and what a second, competing cmp.setup() spec broke
-- NvChad's mappings and thus clangd's auto-import).
--
-- C/C++ auto-import: clangd attaches the required #include to a completion
-- item as an `additionalTextEdit`. cmp-nvim-lsp applies that edit when the
-- item is confirmed, so `<C-Space>` then `<CR>` inserts the include for you.
-- That relies on `nvim_lsp` being a configured source and auto-select being
-- enabled -- both come from NvChad's config, which is why it must be preserved.
return function(_, ret)
  local base = ret

  -- Fallback: if this spec somehow runs first, start from NvChad's own config.
  if type(base) ~= "table" or base.mapping == nil then
    base = require "nvchad.configs.cmp"
  end

  local source_names = {
    nvim_lsp = "[LSP]",
    luasnip = "[snip]",
    buffer = "[buf]",
    async_path = "[path]",
    nvim_lua = "[lua]",
  }

  local kind_icons = {
    Text = "󰉿",
    Method = "󰆧",
    Function = "󰊕",
    Constructor = "󰒓",
    Field = "󰇽",
    Variable = "󰂡",
    Class = "󰠱",
    Interface = "󰜰",
    Module = "󰏗",
    Property = "󰜢",
    Unit = "󰑭",
    Value = "󰎠",
    Enum = "󰒻",
    Keyword = "󰌋",
    Snippet = "󰃐",
    Color = "󰏘",
    File = "󰈙",
    Reference = "󰈇",
    Folder = "󰉋",
    EnumMember = "󰒻",
    Constant = "󰏿",
    Struct = "󰙅",
    Event = "󰉁",
    Operator = "󰆕",
    TypeParameter = "󰅲",
  }

  return vim.tbl_deep_extend("force", base, {
    completion = {
      completeopt = "menu,menuone,noselect",
      performance = {
        max_view_entries = 200,
        slow_tick = 60,
      },
    },
    window = {
      completion = {
        border = "rounded",
        winhighlight = "Normal:CmpPmenu,CursorLine:PmenuSel,Search:None",
      },
      documentation = { border = "rounded" },
    },
    formatting = {
      source_names = source_names,
      fields = { "kind", "abbr", "menu" },
      format = function(entry, item)
        -- Kind icon
        local kind = item.kind
        if type(kind) == "number" then
          kind = vim.lsp.protocol.CompletionItemKind[kind]
        end
        local icon = kind_icons[kind] or "󰈙"
        item.kind = (" %s %s "):format(icon, kind or "")

        -- Source name in menu
        if item.menu and entry.source and entry.source.name then
          item.menu = source_names[entry.source.name] or ("[" .. entry.source.name .. "]")
        end
        return item
      end,
    },
  })
end
