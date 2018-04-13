local awful = require(("awful"))
local gears = require(("gears"))
local upower = require(("upower"))
local nm = require(("nm"))
local string = string
local fu = require(("fennel_utils"))
local utils = require(("utils"))
local function _0_(battery)
  do
    local state = battery[("state")]
    local percentage = battery[("percentage")]
    local function _1_()
      if (state) == (("charging")) then
        return battery[("time-to-full")]
      elseif (state) == (("discharging")) then
        return battery[("time-to-empty")]
      elseif (state) == (("fully-charged")) then
        return 0
      end
    end
    local seconds_remaining = _1_()
    local function _2_()
      if (seconds_remaining) > (3600) then
        return string.format(("(%.1f hrs)"), (seconds_remaining / 3600))
      elseif (seconds_remaining) > (60) then
        return string.format(("(%.1f mins)"), (seconds_remaining / 60))
      elseif (seconds_remaining) > (0) then
        return string.format(("(%.1f secs)"), seconds_remaining)
      else
        return ("")
      end
    end
    local time_remaining = _2_()
    return string.format(("Battery: %s %s%% %s"), state, percentage, time_remaining)
  end
end
local battery_format = _0_
local function _1_()
  do
    local textbox = wibox.widget(({[("markup")] = ("Loading..."), [("widget")] = wibox.widget.textbox}))
    local function _2_()
      textbox.text = battery_format(upower[("battery-info")]())
      return nil
    end
    local display = _2_
    display()
    gears.timer(({[("autostart")] = true, [("callback")] = display, [("timeout")] = 30}))
    return wibox.container.margin(textbox, 5, 5, 5, 5)
  end
end
local battery_widget = _1_
local function _2_(network)
  local function _3_(x)
    return (x[("interface")] .. (" ") .. x[("connection")])
  end
  return (("Network: ") .. fu.join((" "), fu.map(_3_, network)))
end
local network_format = _2_
local function _3_()
  do
    local textbox = wibox.widget(({[("markup")] = ("Loading..."), [("widget")] = wibox.widget.textbox}))
    local function _4_()
      textbox.text = network_format(nm[("network-info")]())
      return nil
    end
    local display = _4_
    display()
    gears.timer(({[("autostart")] = true, [("callback")] = display, [("timeout")] = 30}))
    return wibox.container.margin(textbox, 5, 5, 5, 5)
  end
end
local network_widget = _3_
local function _4_(screen)
  do
    local wibox_bottom = awful.wibar(({[("position")] = ("bottom"), [("screen")] = screen}))
    return wibox_bottom[("setup")](wibox_bottom, ({battery_widget(), network_widget(), [("layout")] = wibox.layout.align.horizontal}))
  end
end
local init = _4_
return ({[("init")] = init})
