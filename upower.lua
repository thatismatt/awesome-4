local lgi = require("lgi")
local upower_glib = lgi.require("UPowerGlib")
local fu = require("fennel_utils")
local client = upower_glib.Client()
local function battery_info()
  local function _0_(d)
    return (d.kind == "battery")
  end
  local function _1_(d)
    return {["time-to-empty"] = d["time-to-empty"], ["time-to-full"] = d["time-to-full"], kind = upower_glib.Device.kind_to_string(d.kind), percentage = d.percentage, state = upower_glib.Device.state_to_string(d.state)}
  end
  return fu.first(fu.filter(_0_, fu.map(_1_, client:get_devices())))
end
return {["battery-info"] = battery_info}
