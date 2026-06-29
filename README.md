# Assetto Corsa MFD display

Multi Function Display (MFD) for Assetto Corsa.

## Overview

This project is a Lua app for Assetto Corsa that provides a fixed 350x300 pixel display with several race-relevant information screens:

- **REL**: relative comparison with cars ahead and behind
- **TIM**: lap times, deltas, and sector information
- **WX**: weather conditions, transition, wind, grip, and rain
- **CAR**: car details such as ABS, TC, fuel, and brake bias
- **TYR**: tyre temperature, wear, and pressure

## Project structure

- `manifest.ini` — app metadata and window configuration
- `MFD.lua` — main entry point and page management
- `src/helpers.lua` — drawing utilities, colors, and bar rendering
- `src/relative.lua` — relative positions display
- `src/timings.lua` — lap and sector timing display
- `src/weather.lua` — weather and track condition display
- `src/car.lua` — car parameters display
- `src/tyres.lua` — tyre condition display
- `src/settings.lua` — controls configuration and relative-car count settings
- `icons/` — app icon and related icons

## Features

- Switch between pages using configurable buttons or keyboard keys
- Display rain condition and intensity trend
- Show current lap, last lap, best lap, and sector comparisons
- Display ABS, TC, fuel, and tyre pressure status
- Provide compact cockpit-ready information without taking too much screen space

## Usage

1. Copy the app folder into Assetto Corsa's apps directory, for example:
   - `Assetto Corsa/apps/lua/MFD` or `Assetto Corsa/apps/MFD`
2. Start Assetto Corsa
3. Enable the `MFD` app from the in-race apps list
4. Use the configured navigation buttons to switch between screens
5. Open the gear icon in the top bar to adjust controls and the number of cars shown in `REL` mode

## Controls

- Navigation buttons `NEXT` / `PREV` can be assigned to:
  - keyboard keys
  - wheel or joystick buttons
- In the settings screen, press the relevant field and then press the desired key or button
- Adjust the number of cars shown ahead/behind in relative mode

## Available pages

- `REL` — shows relative positions and gaps to nearby cars
- `TIM` — shows lap and sector times for current, last, and best laps
- `WX` — shows weather, wind, grip, and rain
- `CAR` — shows car parameters like ABS, TC, fuel, and bias
- `TYR` — shows tyre condition: temperature, wear, and pressure

## Notes

- The app is built for Assetto Corsa and depends on simulation APIs (`ac.getSim`, `ac.getCar`, `sim.weatherConditions`, etc.)
- The window is fixed at `350x300` pixels and titleless for cockpit-style information display

## License

The project includes a `LICENSE` file in the repository.
