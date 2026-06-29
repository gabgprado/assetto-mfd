local c = require('src/colors')
local h = require('src/helpers')
local M = {}

local PAGE_ICONS = { ui.Icons.TimeAttack, ui.Icons.Cloud, ui.Icons.Car }
local PAGE_NAMES = { 'REL', 'WX', 'CAR' }

function M.drawHeader(W, currentPage, PAGE_MAX)
  local H = 26
  ui.drawRectFilled(vec2(0, 0), vec2(W, H), c.BG_HEADER)

  local tabW = math.floor(W / PAGE_MAX)
  for i = 1, PAGE_MAX do
    local tx = (i - 1) * tabW
    if i == currentPage then
      ui.drawRectFilled(vec2(tx, 0), vec2(tx + tabW, H), c.BG_CELL)
      ui.drawLine(vec2(tx, H - 1), vec2(tx + tabW, H - 1), c.C_BLUE, 2)
    end
    
    local iconSize = 14
    local iconX    = tx + math.floor((tabW - iconSize - ui.measureDWriteText(PAGE_NAMES[i], 10).x - 4) / 2)
    local iconY    = math.floor((H - iconSize) / 2)
    local col      = (i == currentPage) and c.C_WHITE or c.C_MUTED
    
    ui.drawIcon(PAGE_ICONS[i], vec2(iconX, iconY), vec2(iconX + iconSize, iconY + iconSize), col)
    ui.dwriteDrawText(PAGE_NAMES[i], 10, vec2(iconX + iconSize + 4, iconY + 2), col)

    if i < PAGE_MAX then
      h.vsep(tx + tabW, 2, H - 2)
    end
  end

  h.sep(0, H, W)
  return H + 1
end

function M.drawFooter(W, y, currentPage, PAGE_MAX)
  local H = 16
  ui.drawRectFilled(vec2(0, y), vec2(W, y + H), c.BG_HEADER)
  h.sep(0, y, W)

  local hint = string.format('[ %d / %d ]  ← prev    next →', currentPage, PAGE_MAX)
  local hw   = ui.measureDWriteText(hint, 9).x
  ui.dwriteDrawText(hint, 9, vec2(math.floor((W - hw) / 2), y + 4), c.C_MUTED)
end

return M
