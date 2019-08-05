local awful = require("awful")
local wibox = require("wibox")
local upower = require("upower")
local nm = require("nm")
local fu = require("fennel_utils")
local function battery_widget()
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
  return wibox.container.margin(textbox, 5, 5, 5, 5)
end
local function network_widget()
  local textbox = wibox.widget({markup = "Loading...", widget = wibox.widget.textbox})
  local manager = nm["create-dbus-properties"]("/org/freedesktop/NetworkManager")
  local devices = fu.remove(nm["ignore-device?"], fu.map(nm["create-device"], manager:GetDevices()))
  local update_fn = nil
  local function _0_()
    textbox.text = ("Network: " .. fu.join(" | ", fu.map(nm["device->label"], fu.remove(nm["generic-device?"], devices))))
    return nil
  end
  update_fn = _0_
  update_fn()
  for _, device in ipairs(devices) do
    device:on_properties_changed(update_fn)
  end
  return wibox.container.margin(textbox, 5, 5, 5, 5)
end
local function init(screen)
  local bar = awful.wibar({position = "bottom", screen = screen})
  return bar:setup({battery_widget(), network_widget(), layout = wibox.layout.align.horizontal})
end
return {init = init}
