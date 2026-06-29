local hp = {}

hp.BG         = rgbm(0.10, 0.10, 0.10, 0.92)
hp.BG_HEADER  = rgbm(0.07, 0.07, 0.07, 1)
hp.BG_CELL    = rgbm(0.13, 0.13, 0.13, 1)
hp.BG_WEATHER = rgbm(0.12, 0.12, 0.12, 1)
hp.BG_ME      = rgbm(0.08, 0.16, 0.08, 1)
hp.BORDER     = rgbm(0.22, 0.22, 0.22, 1)
hp.BORDER_SEP = rgbm(0.22, 0.22, 0.22, 1)
hp.BAR_BG     = rgbm(0.18, 0.18, 0.18, 1)
hp.BAR_BLUE   = rgbm(0.30, 0.72, 1.00, 1)
hp.BAR_GREEN  = rgbm(0.30, 0.75, 0.30, 1)
hp.BAR_AMBER  = rgbm(1.00, 0.67, 0.10, 1)

-- cores de texto — labels agora em cinza mais claro para melhor leitura
hp.C_LABEL    = rgbm(0.70, 0.70, 0.70, 1)   -- era 0.40, agora mais legível
hp.C_VALUE    = rgbm(0.95, 0.95, 0.95, 1)
hp.C_WHITE    = rgbm(1.00, 1.00, 1.00, 1)
hp.C_BLUE     = rgbm(0.30, 0.72, 1.00, 1)
hp.C_BLUE_DIM = rgbm(0.53, 0.80, 1.00, 1)
hp.C_AMBER    = rgbm(1.00, 0.67, 0.10, 1)
hp.C_GREEN    = rgbm(0.40, 0.86, 0.40, 1)
hp.C_RED      = rgbm(1.00, 0.35, 0.25, 1)
hp.C_MUTED    = rgbm(0.55, 0.55, 0.55, 1)   -- era 0.35, agora mais legível

function hp.sep(x, y, w)
  ui.drawLine(vec2(x, y), vec2(x + w, y), hp.BORDER_SEP, 1)
  return y + 1
end

function hp.vsep(x, y1, y2)
  ui.drawLine(vec2(x, y1), vec2(x, y2), hp.BORDER_SEP, 1)
end

function hp.lbl(text, x, y, sz)
  ui.dwriteDrawText(text, sz or 10, vec2(x, y), hp.C_LABEL)
end

function hp.val(text, x, y, w, color, size)
  local tw = ui.measureDWriteText(text, size).x
  ui.dwriteDrawText(text, size, vec2(x + w - tw, y), color or hp.C_VALUE)
end

function hp.bar(x, y, w, fill, color)
  ui.drawRectFilled(vec2(x, y), vec2(x + w, y + 4), hp.BAR_BG)
  local fw = math.max(0, math.min(1, fill)) * w
  if fw >= 1 then
    ui.drawRectFilled(vec2(x, y), vec2(x + fw, y + 4), color or hp.BAR_BLUE)
  end
end

function hp.pct(v)
  return string.format('%.1f%%', math.max(0, math.min(1, v)) * 100)
end

-- escala um valor de fonte garantindo mínimo legível
function hp.fs(base, scale)
  return math.max(9, math.floor(base * scale))
end

-- escala uma dimensão de layout
function hp.sc(base, scale)
  return math.max(1, math.floor(base * scale))
end

return hp
