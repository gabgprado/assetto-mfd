local hp = require('src/helpers')
local M  = {}

function M.draw(PAD, W, startY, sim, cfg)
  if not sim then return end
  local myIdx = sim.focusedCar
  local myCar = ac.getCar(myIdx)
  if not myCar then return end

  local cars = {}
  for i = 0, sim.carsCount - 1 do
    local c = ac.getCar(i)
    if c and c.isConnected then
      -- trackProgress: posição real na corrida ignorando racePosition bugado
      -- laps completadas + progresso na volta atual
      local progress = (c.lapCount or 0) + (c.splinePosition or 0)
      local splineDiff = c.splinePosition - myCar.splinePosition
      if splineDiff >  0.5 then splineDiff = splineDiff - 1 end
      if splineDiff < -0.5 then splineDiff = splineDiff + 1 end
      cars[#cars+1] = {
        car      = c,
        gapM     = splineDiff * (sim.trackLengthM or 1),
        isMe     = (i == myIdx),
        progress = progress,
      }
    end
  end

  -- ordena por trackProgress decrescente e atribui posição calculada
  table.sort(cars, function(a, b) return a.progress > b.progress end)
  for i, entry in ipairs(cars) do
    entry.calcPos = i
  end

  -- reordena por gapM para exibição no relative (quem está à frente primeiro)
  table.sort(cars, function(a, b) return a.gapM > b.gapM end)

  local ROW_H = 30
  local mySort = 1
  for i,c in ipairs(cars) do if c.isMe then mySort=i break end end

  -- sozinho: faixa verde no centro
  if #cars <= 1 then
    local H  = ui.windowHeight()
    local cy = startY + math.floor((H - startY - ROW_H) / 2)
    ui.drawRectFilled(vec2(0, cy), vec2(W, cy + ROW_H), hp.BG_ME)
    local name = myCar:driverName() or 'Player'
    if #name > 18 then name = name:sub(1,17)..'.' end
    ui.dwriteDrawText('P1', 11,
      vec2(PAD, cy + 9), hp.C_GREEN)
    ui.dwriteDrawText(name, 13,
      vec2(PAD + 32, cy + 8), hp.C_WHITE)
    hp.val('—', PAD, cy + 8, W - PAD*2, hp.C_GREEN, 13)
    return
  end

  local N     = cfg.relCount or 3
  local first = math.max(1, mySort - N)
  local last  = math.min(#cars, mySort + N)
  local y     = startY

  for i = first, last do
    local e   = cars[i]
    local c   = e.car
    local isMe = e.isMe
    ui.drawRectFilled(vec2(0, y), vec2(W, y + ROW_H), isMe and hp.BG_ME or hp.BG)
    ui.dwriteDrawText('P'..tostring(e.calcPos), 11,
      vec2(PAD, y + 9), isMe and hp.C_GREEN or hp.C_LABEL)
    local name = c:driverName() or '---'
    if #name > 18 then name = name:sub(1,17)..'.' end
    ui.dwriteDrawText(name, 13,
      vec2(PAD + 32, y + 8), isMe and hp.C_WHITE or hp.C_VALUE)
    if isMe then
      hp.val('—', PAD, y + 8, W - PAD*2, hp.C_GREEN, 13)
    elseif c.speedKmh < 5 then
      hp.val(string.format('%.0fm', math.abs(e.gapM)), PAD,
        y + 8, W - PAD*2, hp.C_MUTED, 13)
    else
      local gs  = math.abs(e.gapM) / (c.speedKmh / 3.6)
      local col = e.gapM > 0 and hp.C_BLUE or hp.C_RED
      hp.val(string.format('%s%.1fs', e.gapM > 0 and '+' or '-', gs),
        PAD, y + 8, W - PAD*2, col, 13)
    end
    hp.sep(0, y + ROW_H, W)
    y = y + ROW_H + 1
  end
end

return M
