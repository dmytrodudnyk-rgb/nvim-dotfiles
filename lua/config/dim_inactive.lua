-- Dim inactive windows (tint-style).
-- Generates a dimmed copy of every highlight group on ColorScheme/VimEnter,
-- then applies them via winhighlight on WinLeave and clears on WinEnter.
-- Adjust the two factors below to control intensity (1.0 = no change, 0 = black).
local FG = 0.65 -- foreground: how much to dim syntax colors, text, etc.
local BG = 0.75 -- background: how much to dim window backgrounds

local _winhighlight = ""

local function dim_color(color, factor)
  if not color then return nil end
  local r = math.floor(color / 65536)
  local g = math.floor((color % 65536) / 256)
  local b = color % 256
  return math.max(0, math.floor(r * factor)) * 65536
       + math.max(0, math.floor(g * factor)) * 256
       + math.max(0, math.floor(b * factor))
end

local function rebuild()
  local mappings = {}
  for _, name in ipairs(vim.fn.getcompletion("", "highlight")) do
    if not name:match("^Dim__") then
      local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
      if ok and (hl.fg or hl.bg) then
        local dim = {}
        for k, v in pairs(hl) do dim[k] = v end
        dim.fg = dim_color(hl.fg, FG)
        dim.bg = dim_color(hl.bg, BG)
        vim.api.nvim_set_hl(0, "Dim__" .. name, dim)
        table.insert(mappings, name .. ":Dim__" .. name)
      end
    end
  end
  _winhighlight = table.concat(mappings, ",")
end

vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, { callback = rebuild })
vim.api.nvim_create_autocmd("WinLeave", { callback = function() vim.wo.winhighlight = _winhighlight end })
vim.api.nvim_create_autocmd("WinEnter", { callback = function() vim.wo.winhighlight = "" end })
