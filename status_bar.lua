local awful = require("awful")
local wibox = require("wibox")
local upower = require("upower")
local nm = require("nm")
local fu = require("fennel_utils")
local function icon_file(...)
  return string.format("/home/matt/Pictures/material-design-icons/%s/1x_web/ic_%s_white_18dp.png", ...)
end
local function icon_widget(...)
  return wibox.widget.imagebox(icon_file(...))
end
local function two_line_textbox()
  local line_1 = wibox.widget.textbox("Loading...")
  local line_2 = wibox.widget.textbox("Loading...")
  local function _0_(_241)
    _241["font"] = "Liberation Sans 8"
    return nil
  end
  fu.map(_0_, {line_1, line_2})
  local function _1_(text_1, text_2)
    line_1.markup = text_1
    line_2.markup = text_2
    return nil
  end
  return {["set-text"] = _1_, container = wibox.container.margin(wibox.layout.fixed.vertical(line_1, line_2), 0, 0, 2, 2)}
end
local function icon_2btextbox(text, ...)
  local textbox = wibox.widget.textbox(text)
  local icon = icon_widget(...)
  local container = wibox.layout.fixed.horizontal(wibox.container.margin(icon, 5, 5, 0, 0), textbox)
  return {container = container, icon = icon, textbox = textbox}
end
local function system_widget()
  local icon = icon_widget("places", "all_inclusive")
  local at_textbox = wibox.widget.textbox("Loading...")
  local os_textbox = two_line_textbox()
  local info = {}
  local on_info = nil
  local function _0_(k, v)
    info[k] = v
    at_textbox.text = (info.user .. "@" .. info.host)
    return os_textbox["set-text"](info.description, fu.capitalize(info.codename))
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
  return wibox.layout.fixed.horizontal(wibox.container.margin(wibox.layout.fixed.horizontal(wibox.container.margin(icon, 5, 5, 0, 0), at_textbox), 5, 5, 5, 5), os_textbox.container)
end
local function battery_widget()
  local battery = icon_2btextbox("Loading...", "device", "battery_unknown")
  local time_to_textbox = two_line_textbox()
  local device = upower["create-device"]("/org/freedesktop/UPower/devices/DisplayDevice")
  local update_fn = nil
  local function _0_()
    local _1_ = upower["normalise-device"](device)
    local percentage = _1_["percentage"]
    local state = _1_["state"]
    local time_to_empty = _1_["time-to-empty"]
    local time_to_full = _1_["time-to-full"]
    local charge_level = nil
    if (state == "empty") then
      charge_level = "empty"
    elseif (percentage <= 20) then
      charge_level = 20
    elseif (percentage <= 30) then
      charge_level = 30
    elseif (percentage <= 50) then
      charge_level = 50
    elseif (percentage <= 60) then
      charge_level = 60
    elseif (percentage <= 80) then
      charge_level = 80
    elseif (percentage <= 90) then
      charge_level = 90
    else
      charge_level = "full"
    end
    local image = nil
    local _3_
    if ((state == "charging") or (state == "full")) then
      _3_ = "charging"
    else
    _3_ = nil
    end
    image = icon_file("device", fu.join("_", {"battery", _3_, charge_level}))
    battery.textbox.markup = string.format("%.0f%%", percentage)
    if (state == "charging") then
      time_to_textbox["set-text"](fu["seconds->duration"](time_to_full), "until full")
    elseif (state == "discharging") then
      time_to_textbox["set-text"](fu["seconds->duration"](time_to_empty), "until empty")
    else
      time_to_textbox["set-text"]("", "")
    end
    battery.icon.image = image
    return nil
  end
  update_fn = _0_
  update_fn()
  device:on_properties_changed(update_fn)
  return wibox.layout.fixed.horizontal(wibox.container.margin(battery.container, 5, 5, 5, 5), time_to_textbox.container)
end
local function network_widget()
  local wifi = icon_2btextbox("Loading...", "device", "network_wifi")
  local ethernet = icon_2btextbox("Loading...", "social", "public")
  local vpn = icon_2btextbox("", "action", "lock")
  local nm_properties = nm["create-dbus-properties"]("/org/freedesktop/NetworkManager")
  local network_manager = nm["create-network-manager"]("/org/freedesktop/NetworkManager")
  local update_fn = nil
  local function _0_()
    local device_data = nil
    local function _1_(_2410)
      return _2410.type
    end
    device_data = fu["key-by"](_1_, fu.map(nm["normalise-device"], fu.remove(nm["ignore-device?"], fu.map(nm["create-device"], nm_properties:GetDevices()))))
    do
      local state = nil
      local function _3_()
        local _2_0 = device_data
        if _2_0 then
          local _4_0 = _2_0.ethernet
          if _4_0 then
            return _4_0.state
          else
            return _4_0
          end
        else
          return _2_0
        end
      end
      state = (_3_() or "[unknown]")
      ethernet.container.visible = (state == "activated")
      ethernet.textbox.text = fu.capitalize(state)
    end
    do
      local _2_ = (device_data.wifi or {})
      local ssid = _2_["ssid"]
      local state = _2_["state"]
      local strength = _2_["strength"]
      local strength_level = nil
      if (state ~= "activated") then
        strength_level = "off"
      elseif (strength <= 20) then
        strength_level = "0_bar"
      elseif (strength <= 40) then
        strength_level = "1_bar"
      elseif (strength <= 60) then
        strength_level = "2_bar"
      elseif (strength <= 80) then
        strength_level = "3_bar"
      else
        strength_level = "4_bar"
      end
      if (state == "activated") then
        wifi.textbox.text = (ssid .. " " .. strength .. "%")
      elseif state then
        wifi.textbox.text = fu.capitalize(state)
      else
        wifi.textbox.text = "[unknown]"
      end
      wifi.icon.image = icon_file("device", ("signal_wifi_" .. strength_level))
      wifi["active?"] = (state == "activated")
      wifi.container.visible = (state == "activated")
    end
    local function _3_()
      local _2_0 = device_data
      if _2_0 then
        local _4_0 = _2_0.wifi
        if _4_0 then
          local _5_0 = _4_0.state
          if _5_0 then
            return (_5_0 ~= "activated")
          else
            return _5_0
          end
        else
          return _4_0
        end
      else
        return _2_0
      end
    end
    local function _5_()
      local _4_0 = device_data
      if _4_0 then
        local _6_0 = _4_0.ethernet
        if _6_0 then
          local _7_0 = _6_0.state
          if _7_0 then
            return (_7_0 ~= "activated")
          else
            return _7_0
          end
        else
          return _6_0
        end
      else
        return _4_0
      end
    end
    if (_3_() and _5_()) then
      wifi.container.visible = true
    end
    do
      local _3_0 = device_data
      if _3_0 then
        local _4_0 = _3_0.tun
        if _4_0 then
          local _5_0 = _4_0.state
          if _5_0 then
            vpn.container.visible = (_5_0 == "activated")
          else
            vpn.container.visible = _5_0
          end
        else
          vpn.container.visible = _4_0
        end
      else
        vpn.container.visible = _3_0
      end
    end
    return nil
  end
  update_fn = _0_
  local toggle_wifi_fn = nil
  local function _1_()
    local function _2_()
      if wifi["active?"] then
        return "off"
      else
        return "on"
      end
    end
    return awful.spawn(("nmcli radio wifi " .. _2_()), false)
  end
  toggle_wifi_fn = _1_
  update_fn()
  network_manager:on_properties_changed(update_fn)
  do end (wifi.container):buttons(awful.button({}, 1, toggle_wifi_fn))
  return wibox.container.margin(wibox.layout.fixed.horizontal(ethernet.container, wifi.container, vpn.container), 5, 5, 5, 5)
end
local function mpc_button(image, command)
  local _0_0 = icon_widget("av", image)
  local function _1_()
    return awful.spawn(("mpc " .. command), false)
  end
  _0_0:buttons(awful.button({}, 1, _1_))
  return _0_0
end
local function mpc_widget()
  return wibox.container.margin(wibox.layout.fixed.horizontal(mpc_button("skip_previous", "prev"), mpc_button("fast_rewind", "seek -60"), mpc_button("play_arrow", "toggle"), mpc_button("fast_forward", "seek +60"), mpc_button("skip_next", "next")), 5, 5, 5, 5)
end
local function init(screen)
  local bar = awful.wibar({position = "bottom", screen = screen})
  return bar:setup({system_widget(), {[2] = wibox.layout.fixed.horizontal(battery_widget(), network_widget()), expand = "outside", layout = wibox.layout.align.horizontal}, mpc_widget(), expand = "inside", layout = wibox.layout.align.horizontal})
end
return {init = init}
