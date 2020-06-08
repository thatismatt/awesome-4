local dbus = require("dbus_proxy")
local fu = require("fennel_utils")
local device_states = {"charging", "discharging", "empty", "full"}
local function create_device(path)
  return (dbus.Proxy):new({bus = dbus.Bus.SYSTEM, interface = "org.freedesktop.UPower.Device", name = "org.freedesktop.UPower", path = path})
end
local function normalise_device(device)
  local device_state = device_states[device.State]
  return {["time-to-empty"] = device.TimeToEmpty, ["time-to-full"] = device.TimeToFull, percentage = device.Percentage, state = device_state}
end
return {["create-device"] = create_device, ["normalise-device"] = normalise_device}
