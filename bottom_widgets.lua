local awful = require("awful")
local gears = require("gears")
local upower = require("upower")
local nm = require("nm")
local string = string
local fu = require("fennel_utils")
local utils = require("utils")
local function battery_format(battery)
  local state = battery.state
  local percentage = battery.percentage
  local seconds_remaining
  if (state == "charging") then
    seconds_remaining = battery["time-to-full"]
  elseif (state == "discharging") then
    seconds_remaining = battery["time-to-empty"]
  elseif (state == "fully-charged") then
    seconds_remaining = 0
  end
  local time_remaining
  if (seconds_remaining > 3600) then
    time_remaining = string.format("(%.1f hrs)", (seconds_remaining / 3600))
  elseif (seconds_remaining > 60) then
    time_remaining = string.format("(%.1f mins)", (seconds_remaining / 60))
  elseif (seconds_remaining > 0) then
    time_remaining = string.format("(%.1f secs)", seconds_remaining)
  else
    time_remaining = ""
  end
  return string.format("Battery: %s %s%% %s", state, percentage, time_remaining)
end
local function battery_widget()
  local textbox = wibox.widget({markup = "Loading...", widget = wibox.widget.textbox})
  local display
  local function _0_()
    textbox.text = battery_format(upower["battery-info"]())
    return nil
  end
  display = _0_
  display()
  gears.timer({autostart = true, callback = display, timeout = 30})
  return wibox.container.margin(textbox, 5, 5, 5, 5)
end
local function network_format(data)
  local connectivity = data.connectivity
  local network_info = data["network-info"]
  local function _0_()
    if (connectivity == "FULL") then
      return ""
    else
      return (connectivity .. " ")
    end
  end
  local function _1_(x)
    return (x.interface .. " " .. x.connection)
  end
  return ("Network: " .. _0_() .. fu.join(" ", fu.map(_1_, network_info)))
end
local function network_widget()
  local textbox = wibox.widget({markup = "Loading...", widget = wibox.widget.textbox})
  local display
  local function _0_()
    textbox.text = network_format({["network-info"] = nm["network-info"](), connectivity = nm.connectivity()})
    return nil
  end
  display = _0_
  display()
  gears.timer({autostart = true, callback = display, timeout = 30})
  return wibox.container.margin(textbox, 5, 5, 5, 5)
end
local function init(screen)
  local wibox_bottom = awful.wibar({position = "bottom", screen = screen})
  return wibox_bottom:setup({battery_widget(), network_widget(), layout = wibox.layout.align.horizontal})
end
return {init = init}
