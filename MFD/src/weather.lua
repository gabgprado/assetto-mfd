local hp = require('src/helpers')
local M  = {}

local WN = {
  [0]='Light Thunderstorm',[1]='Thunderstorm',[2]='Heavy Thunderstorm',
  [3]='Light Drizzle',[4]='Drizzle',[5]='Heavy Drizzle',
  [6]='Light Rain',[7]='Rain',[8]='Heavy Rain',
  [9]='Light Snow',[10]='Snow',[11]='Heavy Snow',
  [12]='Light Sleet',[13]='Sleet',[14]='Heavy Sleet',
  [15]='Clear',[16]='Few Clouds',[17]='Scattered Clouds',
  [18]='Broken Clouds',[19]='Overcast',[20]='Fog',
  [21]='Mist',[22]='Smoke',[23]='Haze',[24]='Sand',
  [25]='Dust',[26]='Squalls',[27]='Tornado',[28]='Hurricane',
  [29]='Cold',[30]='Hot',[31]='Windy',[32]='Hail',
}

local WI = nil
local function wicon(t)
  if not WI then
    WI = {
      [0]=ui.Icons.WeatherStormLight,[1]=ui.Icons.WeatherStorm,[2]=ui.Icons.WeatherStorm,
      [3]=ui.Icons.WeatherRainLight,[4]=ui.Icons.WeatherDrizzle,[5]=ui.Icons.WeatherDrizzle,
      [6]=ui.Icons.WeatherRainLight,[7]=ui.Icons.WeatherRain,[8]=ui.Icons.WeatherRain,
      [9]=ui.Icons.WeatherSnowLight,[10]=ui.Icons.WeatherSnow,[11]=ui.Icons.WeatherSnow,
      [12]=ui.Icons.WeatherSleet,[13]=ui.Icons.WeatherSleet,[14]=ui.Icons.WeatherSleet,
      [15]=ui.Icons.WeatherClear,[16]=ui.Icons.WeatherFewClouds,[17]=ui.Icons.WeatherFewClouds,
      [18]=ui.Icons.WeatherOvercast,[19]=ui.Icons.WeatherOvercast,
      [20]=ui.Icons.WeatherFog,[21]=ui.Icons.WeatherFog,[22]=ui.Icons.WeatherFog,[23]=ui.Icons.WeatherFog,
      [24]=ui.Icons.WeatherWarm,[25]=ui.Icons.WeatherWarm,[26]=ui.Icons.WeatherWindy,
      [27]=ui.Icons.WeatherTornado,[28]=ui.Icons.WeatherHurricane,[29]=ui.Icons.WeatherCold,
      [30]=ui.Icons.WeatherHot,[31]=ui.Icons.WeatherWindySun,[32]=ui.Icons.WeatherHail,
    }
  end
  return WI[t] or ui.Icons.WeatherClear
end

function M.draw(PAD, W, startY, sim, cond, rainData, cache)
  local CW = W - PAD*2
  local y  = startY

  -- weather block (altura fixa 56px)
  local WB_H   = 56
  local ICON_S = 28
  local iconType = (sim and sim.weatherType) or 0

  ui.drawRectFilled(vec2(0, y), vec2(W, y + WB_H), hp.BG_WEATHER)
  ui.drawIcon(wicon(iconType),
    vec2(PAD, y + 12), vec2(PAD + ICON_S, y + 12 + ICON_S), hp.C_WHITE)

  local infoX = PAD + ICON_S + 8
  local infoW = CW - ICON_S - 8
  local wName = WN[iconType] or ('Type '..tostring(iconType))
  ui.dwriteDrawText(wName, 13, vec2(infoX, y + 6), hp.C_WHITE)

  -- barra transição + próximo
  local transVal = (cond and cond.transition) or 0
  local nxtName  = WN[(cond and cond.upcomingType) or 0] or ''
  local barY     = y + 24
  ui.drawRectFilled(vec2(infoX, barY), vec2(infoX + infoW, barY + 3), hp.BAR_BG)
  local tw = math.max(0, math.min(1, transVal)) * infoW
  if tw >= 1 then
    ui.drawRectFilled(vec2(infoX, barY), vec2(infoX + tw, barY + 3), hp.C_AMBER)
  end
  local nxtStr = '\xe2\x86\x92 ' .. nxtName
  local nw = ui.measureDWriteText(nxtStr, 11).x
  ui.dwriteDrawText(nxtStr, 11, vec2(infoX + infoW - nw, barY + 5), hp.C_BLUE_DIM)

  y = y + WB_H ; hp.sep(0, y, W) ; y = y + 1

  -- server time (linha única)
  local ROW = 30  -- era 26
  hp.lbl('SERVER TIME', PAD, y + 9)
  hp.val(cache.serverTime, PAD, y + 9, CW, hp.C_WHITE, 13)
  y = y + ROW ; hp.sep(0, y, W) ; y = y + 1

  -- grid 2x2: temps e wind/grip
  local CW2 = math.floor(CW / 2)
  local GH  = 38  -- era 32

  ui.drawRectFilled(vec2(PAD, y),       vec2(PAD+CW2,  y+GH), hp.BG_CELL)
  ui.drawRectFilled(vec2(PAD+CW2, y),   vec2(PAD+CW,   y+GH), hp.BG_CELL)
  hp.vsep(PAD+CW2, y, y+GH)
  hp.lbl('AIR TEMP',  PAD+4,    y+5)
  hp.lbl('ROAD TEMP', PAD+CW2+4, y+5)
  hp.val(string.format('%.1f\xc2\xb0C', sim and sim.ambientTemperature or 0),
    PAD+4,     y+17, CW2-8, hp.C_BLUE,  13)
  hp.val(string.format('%.1f\xc2\xb0C', sim and sim.roadTemperature or 0),
    PAD+CW2+4, y+17, CW2-8, hp.C_AMBER, 13)
  y = y + GH ; hp.sep(0, y, W)

  ui.drawRectFilled(vec2(PAD, y+1),     vec2(PAD+CW2,  y+GH), hp.BG_CELL)
  ui.drawRectFilled(vec2(PAD+CW2, y+1), vec2(PAD+CW,   y+GH), hp.BG_CELL)
  hp.vsep(PAD+CW2, y+1, y+GH)
  hp.lbl(cache.windStr, PAD+4,     y+6)
  hp.lbl('GRIP',        PAD+CW2+4, y+6)
  hp.val(cache.windKmh, PAD+4,     y+18, CW2-8, hp.C_VALUE, 13)
  local grip = (sim and sim.roadGrip) or 1
  hp.val(hp.pct(grip),  PAD+CW2+4, y+18, CW2-8, hp.C_GREEN, 13)
  hp.bar(PAD+CW2+4, y+GH-7, CW2-8, grip, hp.BAR_GREEN)
  y = y + GH ; hp.sep(0, y, W) ; y = y + 1

  -- rain rows
  local RH = 30  -- era 24
  local function rrow(label, val, trend)
    hp.lbl(label, PAD, y + 8)
    if trend and rainData.trendArrow ~= '' then
      local lw2 = ui.measureDWriteText(label, 10).x
      ui.dwriteDrawText(rainData.trendArrow, 10,
        vec2(PAD + lw2, y + 8), rainData.trendColor)
    end
    hp.val(hp.pct(val), PAD, y + 8, CW, hp.C_BLUE, 13)
    hp.bar(PAD, y + RH - 6, CW, val, hp.BAR_BLUE)
    y = y + RH ; hp.sep(0, y, W) ; y = y + 1
  end

  rrow('RAIN INTENSITY', rainData.intensity, true)
  rrow('TRACK WETNESS',  rainData.wetness,   false)
  rrow('PUDDLES',        rainData.water,      false)
end

return M
