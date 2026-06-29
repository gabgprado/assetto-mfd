local hp = require('src/helpers')
local M  = {}

local function msToTime(ms)
  if not ms or ms <= 0 then return '--:--.---' end
  local m = math.floor(ms / 60000)
  return string.format('%d:%06.3f', m, (ms - m*60000) / 1000)
end

local function deltaStr(ms)
  if not ms or ms == 0 then return '--' end
  return string.format('%s%.3f', ms >= 0 and '+' or '-', math.abs(ms)/1000)
end

function M.draw(PAD, W, startY, sim)
  if not sim then return end
  local car = ac.getCar(sim.focusedCar)
  if not car then return end

  local CW    = W - PAD*2
  local y     = startY
  local ROW_H = 36

  -- lap times
  local lapMs  = car.lapTimeMs          or 0
  local lastMs = car.previousLapTimeMs  or 0
  local bestMs = car.bestLapTimeMs      or 0
  local perf   = car.performanceMeter   or 0
  local valid  = car.isLapValid

  local function row(label, valStr, valCol)
    ui.dwriteDrawText(label,  12, vec2(PAD, y + 12), hp.C_LABEL)
    local vw = ui.measureDWriteText(valStr, 14).x
    ui.dwriteDrawText(valStr, 14, vec2(W - PAD - vw, y + 11), valCol)
    y = y + ROW_H ; hp.sep(0, y, W) ; y = y + 1
  end

  row('Current', msToTime(lapMs),  valid and hp.C_WHITE or hp.C_AMBER)
  row('Last',    msToTime(lastMs), hp.C_VALUE)
  row('Best',    msToTime(bestMs), hp.C_GREEN)

  local diffMs  = math.floor(perf * 1000)
  local diffCol = (bestMs > 0) and (diffMs < 0 and hp.C_GREEN or hp.C_RED) or hp.C_MUTED
  row('Diff', bestMs > 0 and deltaStr(diffMs) or '--', diffCol)

  y = y + 0  -- sem espaço extra

  -- sectors
  local curS  = car.currentSplits  or {}
  local lastS = car.lastSplits     or {}
  local bestS = car.bestLapSplits  or {}
  local curSec = car.currentSector or 0
  local nSec   = math.max(#lastS, #bestS, 3)

  local COL_LBL = 24
  local COL_W   = math.floor((CW - COL_LBL) / 3)
  local SEC_H   = 32

  -- cabeçalho setores — altura 22px com separador no fundo
  local HDR_H = 22
  ui.drawRectFilled(vec2(0, y), vec2(W, y + HDR_H), hp.BG_HEADER)
  ui.dwriteDrawText('Current', 10, vec2(PAD + COL_LBL, y + 7), hp.C_WHITE)
  local lhw = ui.measureDWriteText('Last', 10).x
  ui.dwriteDrawText('Last', 10,
    vec2(PAD + COL_LBL + COL_W + math.floor((COL_W-lhw)/2), y + 7), hp.C_WHITE)
  local bhw = ui.measureDWriteText('Best', 10).x
  ui.dwriteDrawText('Best', 10, vec2(W - PAD - bhw, y + 7), hp.C_WHITE)
  y = y + HDR_H ; hp.sep(0, y, W) ; y = y + 1

  for s = 0, nSec - 1 do
    local active = (s == curSec)
    if active then
      ui.drawRectFilled(vec2(0, y), vec2(W, y + SEC_H), rgbm(0.12, 0.18, 0.12, 1))
    end
    ui.dwriteDrawText('S'..tostring(s+1), 11,
      vec2(PAD, y + 10), active and hp.C_WHITE or hp.C_LABEL)

    local function sv(text, cx, col)
      local tw = ui.measureDWriteText(text, 12).x
      ui.dwriteDrawText(text, 12, vec2(cx + COL_W - tw, y + 10), col)
    end

    local cm = curS[s]  ; local lm = lastS[s] ; local bm = bestS[s]
    sv(cm and cm>0 and msToTime(cm) or '--', PAD+COL_LBL, hp.C_VALUE)
    local lc = hp.C_VALUE
    if lm and lm>0 and bm and bm>0 then lc = lm<=bm and hp.C_GREEN or hp.C_VALUE end
    sv(lm and lm>0 and msToTime(lm) or '--', PAD+COL_LBL+COL_W, lc)
    sv(bm and bm>0 and msToTime(bm) or '--', PAD+COL_LBL+COL_W*2, hp.C_GREEN)

    hp.sep(0, y + SEC_H, W) ; y = y + SEC_H + 1
  end
end

return M
