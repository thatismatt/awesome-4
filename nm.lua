local dbus = require("dbus_proxy")
local fu = require("fennel_utils")
local device_states = {[0] = "unknown", [100] = "activated", [10] = "unmanaged", [110] = "deactivating", [120] = "failed", [20] = "unavailable", [30] = "disconnected", [40] = "prepare", [50] = "config", [60] = "need-auth", [70] = "ip-config", [80] = "ip-check", [90] = "secondaries"}
local device_types = {"ethernet", "wifi", "unused1", "unused2", "bt", "olpc-mesh", "wimax", "modem", "infiniband", "bond", "vlan", "adsl", "bridge", "generic", "team", "tun", "ip-tunnel", "macvlan", "vxlan", "veth", "macsec", "dummy", "ppp", "ovs-interface", "ovs-port", "ovs-bridge", "wpan", "6lowpan", "wireguard", "wifi-p2p", [0] = "unknown"}
local ignored_device_types = {bridge = true, tun = true, veth = true}
local function ignore_device_3f(device)
  return ignored_device_types[device_types[device.DeviceType]]
end
local function device_unavailable_3f(device)
  return ("unavailable" == device_states[device.State])
end
local function generic_device_3f(device)
  return ("generic" == device_types[device.DeviceType])
end
local function create_dbus_properties(path)
  return (dbus.Proxy):new({bus = dbus.Bus.SYSTEM, interface = "org.freedesktop.DBus.Properties", name = "org.freedesktop.NetworkManager", path = path})
end
local function create_device(path)
  return (dbus.Proxy):new({bus = dbus.Bus.SYSTEM, interface = "org.freedesktop.NetworkManager.Device", name = "org.freedesktop.NetworkManager", path = path})
end
local function create_wireless_device(path)
  return (dbus.Proxy):new({bus = dbus.Bus.SYSTEM, interface = "org.freedesktop.NetworkManager.Device.Wireless", name = "org.freedesktop.NetworkManager", path = path})
end
local function create_access_point(path)
  return (dbus.Proxy):new({bus = dbus.Bus.SYSTEM, interface = "org.freedesktop.NetworkManager.AccessPoint", name = "org.freedesktop.NetworkManager", path = path})
end
local function normalise_device(device)
  local device_state = device_states[device.State]
  local device_type = device_types[device.DeviceType]
  local ap = nil
  if (device_state == "activated") then
    local _0_0 = device.object_path
    if _0_0 then
      local _1_0 = create_wireless_device(_0_0)
      if _1_0 then
        local _2_0 = _1_0.ActiveAccessPoint
        if _2_0 then
          ap = create_access_point(_2_0)
        else
          ap = _2_0
        end
      else
        ap = _1_0
      end
    else
      ap = _0_0
    end
  else
  ap = nil
  end
  local result = {interface = ("" .. device.Interface), state = device_state, type = device_type}
  if ap then
    result["ssid"] = fu["bytes->string"](ap.Ssid)
    result["strength"] = ap.Strength
  end
  return result
end
return {["create-dbus-properties"] = create_dbus_properties, ["create-device"] = create_device, ["device-unavailable?"] = device_unavailable_3f, ["generic-device?"] = generic_device_3f, ["ignore-device?"] = ignore_device_3f, ["normalise-device"] = normalise_device}
