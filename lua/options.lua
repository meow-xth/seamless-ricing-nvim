require "nvchad.options"

local o = vim.opt

-- ===== Appearance =====
o.termguicolors = true
o.number = true
o.relativenumber = false
o.signcolumn = "yes"
o.cursorline = true
o.cursorlineopt = "both"
o.colorcolumn = "100"
o.laststatus = 3
o.showmode = false
o.showtabline = 2
-- No `o.tabline` override on purpose: NvChad already renders its own tabline
-- (nvchad/ui + base46 "tbline"), and on Neovim 0.12.5 assigning a tabline
-- string that ends in a bare '%' aborts startup with
-- "E539: Illegal character <^@>" from vim/_core/options.
o.fillchars = { eob = " ", diff = "╱", fold = " ", foldopen = "▾", foldclose = "▸" }
o.list = true
o.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Smooth, animated scrolling (native, no plugin, ~0 cost).
-- NOTE: in Neovim 0.12 'smoothscroll' is a boolean; the { timeout, duration }
-- dict form only exists from 0.13 onwards and makes startup abort here.
o.smoothscroll = true
o.scrolloff = 8
o.sidescrolloff = 8
o.wrap = false

-- ===== Performance =====
o.updatetime = 250 -- fewer redraws while typing / LSP progress updates
o.timeoutlen = 400
o.ttimeoutlen = 10 -- makes <Esc> feel instant even with mappings
o.pumheight = 10
o.inccommand = "nosplit" -- keep the last search result visible
o.lazyredraw = false -- hlchunk/treesitter need immediate redraws
o.shortmess:append { I = true, c = true, o = true, O = true, a = true, A = true, s = true, S = true, W = true }
-- NOTE: 'path' is not a valid sessionoptions flag (it would also restore
-- 'runtimepath' from an untrusted session, so it is rejected).
o.sessionoptions = "blank,buffers,curdir,folds,options,tabpages,winsize,terminal"
o.swapfile = false
o.undofile = true
o.backup = false -- undofile covers it; avoids a write on every save

-- ===== UI behaviour =====
o.completeopt = { "menu", "menuone", "noselect" }
o.wildmenu = true
-- NOTE: no `o.wildmode` override -- this Neovim build reports wildmode as a
-- free-form string yet rejects every documented flag ("c", "f", "cf", ...),
-- so assigning it aborts startup with E474.
o.splitkeep = "screen"
o.splitbelow = true
o.splitright = true
o.winborder = "rounded"
o.confirm = true
o.showcmd = false
o.winminheight = 1
o.winheight = 1
-- NOTE: 'scrollfocus' was removed in Neovim 0.12 and 'searchhighlight' was
-- replaced by 'hlsearch' long ago. Setting either aborts startup.

-- ===== Clipboard =====
o.clipboard = "unnamedplus"

-- ===== calm cmdline & messages =====
o.cmdheight = 0 -- cmdline sembunyi sampai dipakai; pesan lewat notify
o.pumblend = 10 -- popup sedikit transparan

-- WSL1 has no working /dev/clipboard bridge; WSL2 already ships the native
-- `wsl` clipboard provider, so only patch the old kernel.
if vim.fn.has "wsl" == 1 then
  local _, _, build = vim.fn.has "wsl2"
  if build ~= 1 then
    vim.g.clipboard = {
      name = "WslClipboard",
      copy = {
        ["+"] = "clip.exe",
        ["*"] = "clip.exe",
      },
      paste = {
        ["+"] = 'powershell.exe -NoProfile -Command [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
        ["*"] = 'powershell.exe -NoProfile -Command [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      },
      cache_enabled = 0,
    }
  end
end
