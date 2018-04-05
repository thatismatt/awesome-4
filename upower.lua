local lgi = require(("lgi"))
local upower_glib = lgi.require(("UPowerGlib"))
local fu = require(("fennel_utils"))
local client = upower_glib.Client()
local function _0_()
  local function _1_(d)
    return (d[("kind")]) == (("battery"))
  end
  local function _2_(d)
    return ({[("kind")] = upower_glib.Device.kind_to_string(d[("kind")]), [("percentage")] = d[("percentage")], [("state")] = upower_glib.Device.state_to_string(d[("state")]), [("time-to-empty")] = d[("time-to-empty")], [("time-to-full")] = d[("time-to-full")]})
  end
  return fu.first(fu.filter(_1_, fu.map(_2_, client[("get_devices")](client))))
end
local battery_info = _0_
return ({[("battery-info")] = battery_info})
