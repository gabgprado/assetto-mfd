local hp = require('src/helpers')
local M  = {}

local listeningFor = nil -- 'next' or 'prev'

local function bindLabel(bindType, bindValue, joy, btn)
  if bindType == 'kbd' and bindValue > 0 then
    return string.format('Keyboard  Key %d', bindValue)
  elseif bindType == 'joy' and joy >= 0 and btn >= 0 then
    return string.format('Wheel  Joy %d  Btn %d', joy, btn)
  end
  return 'Not assigned'
end

function M.draw(PAD, W, startY, cfg)
  local CW = W - PAD * 2
  local y  = startY + 8

  -- título
  ui.dwriteDrawText('SETTINGS', 14, vec2(PAD, y), hp.C_BLUE)
  y = y + 22 ; hp.sep(0, y, W) ; y = y + 10

  -- instrução
  ui.dwriteDrawText('Navigation Controls', 12, vec2(PAD, y), hp.C_WHITE)
  y = y + 16
  ui.dwriteDrawText('Accepts wheel buttons or keyboard keys.', 11,
    vec2(PAD, y), hp.C_LABEL)
  y = y + 22

  -- ── NEXT ─────────────────────────────────────────────────────
  ui.dwriteDrawText('NEXT PAGE', 11, vec2(PAD, y), hp.C_LABEL)
  y = y + 14

  local nextLbl = listeningFor == 'next'
    and 'Press a button or key...'
    or  bindLabel(cfg.bindTypeNext, cfg.bindValueNext, cfg.joyNext, cfg.btnNext)

  local nextCol = listeningFor == 'next' and hp.C_AMBER or hp.C_VALUE
  ui.drawRectFilled(vec2(PAD, y), vec2(PAD + CW, y + 28), hp.BG_CELL, 3, ui.CornerFlags.All)
  ui.dwriteDrawText(nextLbl, 12, vec2(PAD + 8, y + 8), nextCol)
  ui.setCursor(vec2(PAD, y))
  if ui.invisibleButton('##setnext', vec2(CW, 28)) then
    listeningFor = 'next'
  end
  y = y + 34

  -- ── PREV ─────────────────────────────────────────────────────
  ui.dwriteDrawText('PREV PAGE', 11, vec2(PAD, y), hp.C_LABEL)
  y = y + 14

  local prevLbl = listeningFor == 'prev'
    and 'Press a button or key...'
    or  bindLabel(cfg.bindTypePrev, cfg.bindValuePrev, cfg.joyPrev, cfg.btnPrev)

  local prevCol = listeningFor == 'prev' and hp.C_AMBER or hp.C_VALUE
  ui.drawRectFilled(vec2(PAD, y), vec2(PAD + CW, y + 28), hp.BG_CELL, 3, ui.CornerFlags.All)
  ui.dwriteDrawText(prevLbl, 12, vec2(PAD + 8, y + 8), prevCol)
  ui.setCursor(vec2(PAD, y))
  if ui.invisibleButton('##setprev', vec2(CW, 28)) then
    listeningFor = 'prev'
  end
  y = y + 34

  -- ── CAPTURA ───────────────────────────────────────────────────
  if listeningFor then
    -- teclado
    for k = 1, 255 do
      if ac.isKeyDown(k) then
        if listeningFor == 'next' then
          cfg.bindTypeNext = 'kbd' ; cfg.bindValueNext = k
          cfg.joyNext = -1         ; cfg.btnNext = -1
        else
          cfg.bindTypePrev = 'kbd' ; cfg.bindValuePrev = k
          cfg.joyPrev = -1         ; cfg.btnPrev = -1
        end
        listeningFor = nil ; break
      end
    end
    -- joystick / volante
    if listeningFor then
      for j = 0, 15 do
        for b = 0, 127 do
          if ac.isJoystickButtonPressed(j, b) then
            if listeningFor == 'next' then
              cfg.bindTypeNext = 'joy' ; cfg.joyNext = j ; cfg.btnNext = b
              cfg.bindValueNext = -1
            else
              cfg.bindTypePrev = 'joy' ; cfg.joyPrev = j ; cfg.btnPrev = b
              cfg.bindValuePrev = -1
            end
            listeningFor = nil ; break
          end
        end
        if not listeningFor then break end
      end
    end
  end

  hp.sep(0, y, W) ; y = y + 10

  -- ── CARS NO RELATIVE ──────────────────────────────────────────
  ui.dwriteDrawText('CARS SHOWN AHEAD / BEHIND', 12, vec2(PAD, y), hp.C_WHITE)
  y = y + 18

  local relCount = cfg.relCount or 3
  local btnW     = math.floor((CW - 9) / 10)
  for i = 1, 10 do
    local bx  = PAD + (i-1) * (btnW + 1)
    local act = relCount == i
    ui.drawRectFilled(vec2(bx, y), vec2(bx + btnW, y + 28),
      act and hp.C_BLUE or hp.BG_CELL, 2, ui.CornerFlags.All)
    local tw = ui.measureDWriteText(tostring(i), 12).x
    ui.dwriteDrawText(tostring(i), 12,
      vec2(bx + math.floor((btnW - tw) / 2), y + 8),
      act and hp.C_WHITE or hp.C_MUTED)
    ui.setCursor(vec2(bx, y))
    if ui.invisibleButton('##rel'..i, vec2(btnW, 28)) then
      cfg.relCount = i
    end
  end
  y = y + 36

  ui.dwriteDrawText('Click the gear icon to close', 11, vec2(PAD, y), hp.C_MUTED)

  return y
end

return M
