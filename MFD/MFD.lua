--[[
  MFD - Multi Function Display v1.6
  Fixed size: 350x300
  Pages: REL | TIM | WX | CAR | TYR
]]

local hp       = require('src/helpers')
local relative = require('src/relative')
local timings  = require('src/timings')
local weather  = require('src/weather')
local car      = require('src/car')
local tyres    = require('src/tyres')
local settings = require('src/settings')

local cfg = ac.storage({
  bindTypeNext  = 'joy',
  bindValueNext = -1,
  joyNext       = -1,
  btnNext       = -1,
  bindTypePrev  = 'joy',
  bindValuePrev = -1,
  joyPrev       = -1,
  btnPrev       = -1,
  relCount      = 3,
}, 'mfd_v13_')

local page         = 1
local PAGE_MAX     = 5
local showSettings = false

local sim  = nil
local cond = nil

local rainData = {
  intensity  = 0,
  wetness    = 0,
  water      = 0,
  trendArrow = '',
  trendColor = rgbm(0.6, 0.6, 0.6, 1)
}

local rainHistory     = {}
local TREND_WINDOW    = 10.0
local UPDATE_INTERVAL = 0.5
local timer           = 0

local cache = {
  serverTime = '00:00:00',
  windStr    = 'WIND  N',
  windKmh    = '0 km/h',
}

local function updateTrend(now, intensity)
  rainHistory[#rainHistory + 1] = { t = now, v = intensity }
  local cutoff = now - TREND_WINDOW
  while #rainHistory > 1 and rainHistory[1].t < cutoff do
    table.remove(rainHistory, 1)
  end
  if #rainHistory < 2 then rainData.trendArrow = '' ; return end
  local delta = rainHistory[#rainHistory].v - rainHistory[1].v
  if     delta >  0.01 then rainData.trendArrow = ' \xe2\x86\x91' ; rainData.trendColor = hp.C_RED
  elseif delta < -0.01 then rainData.trendArrow = ' \xe2\x86\x93' ; rainData.trendColor = hp.C_GREEN
  else                       rainData.trendArrow = ' \xe2\x86\x92' ; rainData.trendColor = hp.C_MUTED
  end
end

local WIND_DIRS = {'N','NE','E','SE','S','SW','W','NW'}
local function windDir(deg)
  if not deg then return 'N' end
  return WIND_DIRS[math.floor((deg + 22.5) / 45) % 8 + 1]
end

local prevNextActive, prevPrevActive = false, false

function script.update(dt)
  local nextNow = false
  if cfg.bindTypeNext == 'kbd' and cfg.bindValueNext > 0 then
    nextNow = ac.isKeyDown(cfg.bindValueNext)
  elseif cfg.joyNext >= 0 and cfg.btnNext >= 0 then
    nextNow = ac.isJoystickButtonPressed(cfg.joyNext, cfg.btnNext)
  end
  local prevNow = false
  if cfg.bindTypePrev == 'kbd' and cfg.bindValuePrev > 0 then
    prevNow = ac.isKeyDown(cfg.bindValuePrev)
  elseif cfg.joyPrev >= 0 and cfg.btnPrev >= 0 then
    prevNow = ac.isJoystickButtonPressed(cfg.joyPrev, cfg.btnPrev)
  end
  if not showSettings then
    if nextNow and not prevNextActive then page = page % PAGE_MAX + 1
    elseif prevNow and not prevPrevActive then page = (page - 2) % PAGE_MAX + 1
    end
  end
  prevNextActive = nextNow
  prevPrevActive = prevNow

  timer = timer + dt
  if timer < UPDATE_INTERVAL then return end
  timer = 0

  sim = ac.getSim()
  if not sim then return end

  cond = sim.weatherConditions
  if cond then
    rainData.intensity = cond.rainIntensity or 0
    rainData.wetness   = cond.rainWetness   or 0
    rainData.water     = cond.rainWater     or 0
  else
    rainData.intensity = sim.rainIntensity  or 0
    rainData.wetness   = sim.rainWetness    or 0
    rainData.water     = sim.rainWater      or 0
  end
  updateTrend(sim.time / 1000.0, rainData.intensity)

  cache.serverTime = string.format('%02d:%02d:%02d',
    sim.timeHours, sim.timeMinutes, sim.timeSeconds)
  local wind    = ac.getWindVelocity()
  local windKmh = wind and (math.sqrt(wind.x*wind.x + wind.z*wind.z) * 3.6) or 0
  cache.windStr = 'WIND  ' .. windDir(sim.windDirectionDeg)
  cache.windKmh = string.format('%.0f km/h', windKmh)
end

-- ── HEADER ────────────────────────────────────────────────────

local PAGE_ICONS = {
  ui.Icons.Leaderboard,  -- REL
  ui.Icons.Stopwatch,    -- TIM
  ui.Icons.Cloud,        -- WX
  ui.Icons.Speedometer,  -- CAR
  ui.Icons.Wheel,        -- TYR
}
local PAGE_NAMES = { 'REL', 'TIM', 'WX', 'CAR', 'TYR' }
local HEADER_H   = 28

local function drawHeader(W)
  ui.drawRectFilled(vec2(0, 0), vec2(W, HEADER_H), hp.BG_HEADER)

  local tabsW = W - 28
  local tabW  = math.floor(tabsW / PAGE_MAX)

  for i = 1, PAGE_MAX do
    local tx = (i - 1) * tabW
    if i == page and not showSettings then
      ui.drawRectFilled(vec2(tx, 0), vec2(tx + tabW, HEADER_H), hp.BG_CELL)
      ui.drawLine(vec2(tx, HEADER_H - 1), vec2(tx + tabW, HEADER_H - 1), hp.C_BLUE, 2)
    end
    local iconS = 12
    local nameW = ui.measureDWriteText(PAGE_NAMES[i], 10).x
    local iconX = tx + math.floor((tabW - iconS - nameW - 3) / 2)
    local iconY = math.floor((HEADER_H - iconS) / 2)
    local col   = (i == page and not showSettings) and hp.C_WHITE or hp.C_MUTED
    ui.drawIcon(PAGE_ICONS[i], vec2(iconX, iconY), vec2(iconX + iconS, iconY + iconS), col)
    ui.dwriteDrawText(PAGE_NAMES[i], 10, vec2(iconX + iconS + 3, iconY + 1), col)
    ui.setCursor(vec2(tx, 0))
    if ui.invisibleButton('##tab'..i, vec2(tabW, HEADER_H)) then
      page = i ; showSettings = false
    end
    if i < PAGE_MAX then hp.vsep(tx + tabW, 2, HEADER_H - 2) end
  end

  -- gear
  local gearCol = showSettings and hp.C_AMBER or hp.C_MUTED
  hp.vsep(W - 28, 2, HEADER_H - 2)
  ui.drawIcon(ui.Icons.Settings, vec2(W - 21, 7), vec2(W - 7, 21), gearCol)
  ui.setCursor(vec2(W - 28, 0))
  if ui.invisibleButton('##gear', vec2(28, HEADER_H)) then
    showSettings = not showSettings
  end

  hp.sep(0, HEADER_H, W)
  return HEADER_H + 1
end

-- ── MAIN ──────────────────────────────────────────────────────

function script.windowMain(dt)
  local W   = ui.windowWidth()
  local H   = ui.windowHeight()
  local PAD = 8

  ui.drawRectFilled(vec2(0, 0), vec2(W, H), hp.BG)
  ui.drawRect(vec2(0, 0), vec2(W, H), hp.BORDER)

  if not sim then
    ui.dwriteDrawText('Waiting for session...', 12, vec2(PAD, PAD + 40), hp.C_LABEL)
    return
  end

  local startY = drawHeader(W)

  if showSettings then
    settings.draw(PAD, W, startY, cfg)
  elseif page == 1 then
    relative.draw(PAD, W, startY, sim, cfg)
  elseif page == 2 then
    timings.draw(PAD, W, startY, sim)
  elseif page == 3 then
    weather.draw(PAD, W, startY, sim, cond, rainData, cache)
  elseif page == 4 then
    car.draw(PAD, W, startY, sim)
  elseif page == 5 then
    tyres.draw(PAD, W, startY, sim)
  end
end
