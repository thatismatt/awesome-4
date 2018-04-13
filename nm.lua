local lgi = require("lgi")
local nm_glib = lgi.require("NM")
local fu = require("fennel_utils")
local client = nm_glib.Client()
local function _0_()
  local function _1_(d)
    return (d.state) == ("ACTIVATED")
  end
  local function _2_(d)
    local dt = d["device-type"]
    return ((dt) == ("WIFI") or (dt) == ("ETHERNET"))
  end
  local function _3_(d)
    local connection = d:get_active_connection()
    local function _4_()
      if connection then
        return connection:get_id()
      end
    end
    return ({["device-type"] = d["device-type"], connection = _4_(), interface = d.interface, state = d.state})
  end
  return fu.filter(_1_, fu.filter(_2_, fu.map(_3_, client:get_devices())))
end
local network_info = _0_
return ({["network-info"] = network_info})
