local lgi = require("lgi")
local nm_glib = lgi.require("NM")
local fu = require("fennel_utils")
local client = nm_glib.Client()
local function network_info()
  local function _0_(d)
    return (d.state == "ACTIVATED")
  end
  local function _1_(d)
    local dt = d["device-type"]
    return ((dt == "WIFI") or (dt == "ETHERNET"))
  end
  local function _2_(d)
    local connection = d:get_active_connection()
    local function _3_()
      if connection then
        return connection:get_id()
      end
    end
    return {["device-type"] = d["device-type"], connection = _3_(), interface = d.interface, state = d.state}
  end
  return fu.filter(_0_, fu.filter(_1_, fu.map(_2_, client:get_devices())))
end
local function connectivity()
  return client:get_connectivity()
end
return {["network-info"] = network_info, connectivity = connectivity}
