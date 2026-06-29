local hp = require('src/helpers')
local M  = {}

local function tempColor(t)
  if t < 60 then return hp.C_BLUE
  elseif t < 70 then return hp.C_VALUE
  elseif t < 100 then return hp.C_GREEN
  elseif t < 110 then return hp.C_AMBER
  else return hp.C_RED end
end

local function wearColor(v)
  if v > 0.70 then return hp.C_GREEN
  elseif v > 0.40 then return hp.C_AMBER
  else return hp.C_RED end
end

local function cell(x, y, w, h, lbl, temp, inner, outer, wear, pressure)
  local P = 6
  hp.lbl(lbl, x+P, y+4)
  ui.dwriteDrawText(string.format('%.0f\xc2\xb0', temp), 20,
    vec2(x+P, y+15), tempColor(temp))
  ui.dwriteDrawText(string.format('I: %.0f  O: %.0f', inner, outer), 10,
    vec2(x+P, y+38), hp.C_LABEL)
  local wStr = string.format('%.0f%%', math.max(0,math.min(1,wear))*100)
  local pStr = string.format('%.1fp', pressure)
  ui.dwriteDrawText(wStr, 14, vec2(x+P, y+h-20), wearColor(wear))
  local pw = ui.measureDWriteText(pStr, 14).x
  ui.dwriteDrawText(pStr, 14, vec2(x+w-P-pw, y+h-20), hp.C_LABEL)
end

function M.draw(PAD, W, startY, sim)
  if not sim then return end
  local CW  = W - PAD*2
  local car = ac.getCar(sim.focusedCar)
  if not car then return end

  local y = startY

  -- compound
  hp.lbl('TYRE COMPOUND', PAD, y+6)
  hp.val(car:tyresName() or '—', PAD, y+6, CW, hp.C_WHITE, 13)
  y = y + 24 ; hp.sep(0, y, W) ; y = y + 1

  -- coleta dados
  local wheels = car.wheels
  local d = {}
  for i = 0,3 do
    local w = wheels and wheels[i]
    d[i] = {
      temp     = w and w.tyreMiddleTemperature or 0,
      inner    = w and w.tyreInnerTemperature  or 0,
      outer    = w and w.tyreOuterTemperature  or 0,
      wear     = w and w.tyreWear              or 1,
      pressure = w and w.tyrePressure          or 0,
    }
  end

  local CW2   = math.floor(CW / 2)
  local CH    = 84  -- increased for inner/outside temperature line
  local SUB_S = 10

  -- labels de coluna
  local function clabel(text, cx, cw2)
    local tw = ui.measureDWriteText(text, SUB_S).x
    ui.dwriteDrawText(text, SUB_S,
      vec2(cx + math.floor((cw2-tw)/2), y+3), hp.C_WHITE)
  end
  clabel('LEFT',  PAD,      CW2)
  clabel('RIGHT', PAD+CW2,  CW2)
  y = y + 14

  -- FRONT
  local fw = ui.measureDWriteText('FRONT', SUB_S).x
  ui.dwriteDrawText('FRONT', SUB_S,
    vec2(PAD + math.floor((CW-fw)/2), y+2), hp.C_LABEL)
  y = y + 13

  ui.drawRectFilled(vec2(PAD, y),      vec2(PAD+CW2, y+CH), hp.BG_CELL)
  ui.drawRectFilled(vec2(PAD+CW2, y),  vec2(PAD+CW,  y+CH), hp.BG_CELL)
  hp.vsep(PAD+CW2, y, y+CH)
  cell(PAD,     y, CW2, CH, 'FL', d[0].temp, d[0].inner, d[0].outer, d[0].wear, d[0].pressure)
  cell(PAD+CW2, y, CW2, CH, 'FR', d[1].temp, d[1].inner, d[1].outer, d[1].wear, d[1].pressure)
  y = y + CH ; hp.sep(0, y, W) ; y = y + 1

  -- REAR
  local rw = ui.measureDWriteText('REAR', SUB_S).x
  ui.dwriteDrawText('REAR', SUB_S,
    vec2(PAD + math.floor((CW-rw)/2), y+2), hp.C_LABEL)
  y = y + 13

  ui.drawRectFilled(vec2(PAD, y),      vec2(PAD+CW2, y+CH), hp.BG_CELL)
  ui.drawRectFilled(vec2(PAD+CW2, y),  vec2(PAD+CW,  y+CH), hp.BG_CELL)
  hp.vsep(PAD+CW2, y, y+CH)
  cell(PAD,     y, CW2, CH, 'RL', d[2].temp, d[2].inner, d[2].outer, d[2].wear, d[2].pressure)
  cell(PAD+CW2, y, CW2, CH, 'RR', d[3].temp, d[3].inner, d[3].outer, d[3].wear, d[3].pressure)
  y = y + CH
end

return M
