local awful = require("awful")
local wibox = require("wibox")
local upower = require("upower")
local nm = require("nm")
local fu = require("fennel_utils")
local naughty = require("naughty")
local function icon_widget(...)
  return wibox.widget.imagebox(string.format("/home/matt/Pictures/material-design-icons/%s/1x_web/ic_%s_white_18dp.png", ...))
end
local function system_widget()
  local textbox = wibox.widget.textbox("Loading...")
  local info = {}
  local on_info = nil
  local function _0_(k, v)
    info[k] = v
    textbox.text = string.format("%s@%s (%s %s)", info.user, info.host, info.description, info.codename)
    return nil
  end
  on_info = _0_
  local function _1_(_241)
    return on_info("user", string.gsub(_241, "%s", ""))
  end
  awful.spawn.easy_async("whoami", _1_)
  local function _2_(_241)
    return on_info("host", string.gsub(_241, "%s", ""))
  end
  awful.spawn.easy_async("hostname", _2_)
  local function _3_(_241)
    local k, v = string.match(_241, "^(.*):%s(.*)$")
    return on_info(string.lower(k), v)
  end
  awful.spawn.with_line_callback("lsb_release -a", {stdout = _3_})
  return wibox.container.margin(textbox, 5, 5, 5, 5)
end
local function battery_widget()
  local icon = icon_widget("device", "battery_full")
  local textbox = wibox.widget({markup = "Loading...", widget = wibox.widget.textbox})
  local device = upower["create-device"]("/org/freedesktop/UPower/devices/DisplayDevice")
  local update_fn = nil
  local function _0_()
    textbox.text = upower["device->label"](device)
    return nil
  end
  update_fn = _0_
  update_fn()
  device:on_properties_changed(update_fn)
  return wibox.container.margin(wibox.layout.fixed.horizontal(wibox.container.margin(icon, 5, 5, 0, 0), textbox), 5, 5, 5, 5)
end
local function network_widget()
  local icon = icon_widget("device", "network_wifi")
  local textbox = wibox.widget({markup = "Loading...", widget = wibox.widget.textbox})
  local manager = nm["create-dbus-properties"]("/org/freedesktop/NetworkManager")
  local devices = fu.remove(nm["ignore-device?"], fu.map(nm["create-device"], manager:GetDevices()))
  local update_fn = nil
  local function _0_()
    textbox.text = fu.join(" | ", fu.map(nm["device->label"], fu.remove(nm["device-unavailable?"], fu.remove(nm["generic-device?"], devices))))
    return nil
  end
  update_fn = _0_
  update_fn()
  for _, device in ipairs(devices) do
    device:on_properties_changed(update_fn)
  end
  return wibox.container.margin(wibox.layout.fixed.horizontal(wibox.container.margin(icon, 5, 5, 0, 0), textbox), 5, 5, 5, 5)
end
local function mpc_button(image, command)
  local img = icon_widget("av", image)
  local function _0_()
    return awful.spawn(("mpc " .. command), false)
  end
  img:buttons(awful.button({}, 1, _0_))
  return img
end
local function mpc_widget()
  return wibox.container.margin(wibox.layout.fixed.horizontal(mpc_button("skip_previous", "prev"), mpc_button("fast_rewind", "seek -60"), mpc_button("play_arrow", "toggle"), mpc_button("fast_forward", "seek +60"), mpc_button("skip_next", "next")), 5, 5, 5, 5)
end
local function init(screen)
  local bar = awful.wibar({position = "bottom", screen = screen})
  return bar:setup({system_widget(), {[2] = wibox.layout.fixed.horizontal(battery_widget(), network_widget()), expand = "outside", layout = wibox.layout.align.horizontal}, mpc_widget(), expand = "inside", layout = wibox.layout.align.horizontal})
end
return {init = init}
