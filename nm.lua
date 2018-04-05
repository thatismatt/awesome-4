local lgi = require(("lgi"))
local nm_glib = lgi.require(("NM"))
local fu = require(("fennel_utils"))
local client = nm_glib.Client()
local function _0_()
  local function _1_(d)
    do
      local dt = d[("device-type")]
      return ((dt) == (("WIFI")) or (dt) == (("ETHERNET")))
    end
  end
  local function _2_(d)
    return ({[("device-type")] = d[("device-type")], [("interface")] = d[("interface")], [("state")] = d[("state")]})
  end
  return fu.filter(_1_, fu.map(_2_, client[("get_devices")](client)))
end
local network_info = _0_
return ({[("network-info")] = network_info})
