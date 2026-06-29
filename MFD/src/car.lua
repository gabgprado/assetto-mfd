local hp = require('src/helpers')
local M  = {}

local function fuelTimeLeft(fuel, fuelPerLap, sim)
  if not fuel or not fuelPerLap or fuelPerLap < 0.05 or not sim then return '—' end
  local c = ac.getCar(sim.focusedCar)
  local bestMs = c and c.bestLapTimeMs or 0
  if bestMs < 1000 then return '—' end
  local totalMs = (fuel / fuelPerLap) * bestMs
  local h = math.floor(totalMs / 3600000)
  local m = math.floor((totalMs % 3600000) / 60000)
  local s = math.floor((totalMs % 60000) / 1000)
  return h > 0 and string.format('%dh %02dm', h, m)
                or string.format('%dm %02ds', m, s)
end

function M.draw(PAD, W, startY, sim)
  if not sim then return end
  local CW  = W - PAD*2
  local car = ac.getCar(sim.focusedCar)
  if not car then return end

  local y   = startY
  local ROW = 40  -- era 34

  local function row(label, valStr, valCol, withBar, barVal, barCol)
    hp.lbl(label, PAD, y + 6)
    hp.val(valStr, PAD, y + 16, CW, valCol or hp.C_VALUE, 12)
    if withBar then
      hp.bar(PAD, y + ROW - 8, CW, barVal or 0, barCol or hp.BAR_BLUE)
    end
    y = y + ROW ; hp.sep(0, y, W) ; y = y + 1
  end

  -- ABS / TC / TC2 em tile 3x1
  local TILE_H = 40
  local TILE_W = math.floor(CW / 3)
  ui.drawRectFilled(vec2(PAD, y), vec2(PAD + CW, y + TILE_H), hp.BG_CELL)
  local items = {
    { lbl='ABS', val=car.absMode or 0 },
    { lbl='TC',  val=car.tractionControlMode or 0 },
    { lbl='TC2', val=car.tractionControl2 or 0 },
  }
  for i, item in ipairs(items) do
    local cx = PAD + (i-1) * TILE_W
    if i > 1 then hp.vsep(cx, y, y + TILE_H) end
    hp.lbl(item.lbl, cx + 4, y + 5)
    local valStr = item.val > 0 and tostring(math.floor(item.val)) or 'OFF'
    local valCol = item.val > 0 and hp.C_AMBER or hp.C_MUTED
    local vw = ui.measureDWriteText(valStr, 14).x
    ui.dwriteDrawText(valStr, 14,
      vec2(cx + math.floor((TILE_W - vw) / 2), y + 18), valCol)
  end
  y = y + TILE_H ; hp.sep(0, y, W) ; y = y + 1

  local absMode = car.absMode or 0 -- mantido para compatibilidade
  local tcMode  = car.tractionControlMode or 0
  local tc2     = car.tractionControl2 or 0

  local bb = car.brakeBias or 0.5
  row('BRAKE BIAS', string.format('%.1f%%', bb*100), hp.C_BLUE, true, bb, hp.BAR_BLUE)

  local fuel    = car.fuel or 0
  local fuelMax = car.maxFuel or 1
  row('FUEL', string.format('%.1f L', fuel), hp.C_GREEN, true, fuel/math.max(1,fuelMax), hp.BAR_GREEN)

  local fpl = car.fuelPerLap or 0
  row('FUEL / LAP', fpl > 0 and string.format('%.2f L', fpl) or '—', hp.C_VALUE)

  local lapsLeft = fpl > 0.05 and math.floor(fuel/fpl) or 0
  row('LAPS LEFT', lapsLeft > 0 and tostring(lapsLeft) or '—', hp.C_AMBER)

  row('FUEL TIME LEFT', fuelTimeLeft(fuel, fpl, sim), hp.C_AMBER)
end

return M
