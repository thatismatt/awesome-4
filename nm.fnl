(local dbus (require "dbus_proxy"))
(local fu (require "fennel_utils"))

;; https://developer.gnome.org/NetworkManager/unstable/nm-dbus-types.html#NMDeviceState
(local device-states
       {0   :unknown
        10  :unmanaged
        20  :unavailable
        30  :disconnected
        40  :prepare
        50  :config
        60  :need-auth
        70  :ip-config
        80  :ip-check
        90  :secondaries
        100 :activated
        110 :deactivating
        120 :failed})

(local device-types
       {0  :unknown
        14 :generic
        1  :ethernet
        2  :wifi
        3  :unused1
        4  :unused2
        5  :bt
        6  :olpc-mesh
        7  :wimax
        8  :modem
        9  :infiniband
        10 :bond
        11 :vlan
        12 :adsl
        13 :bridge
        15 :team
        16 :tun
        17 :ip-tunnel
        18 :macvlan
        19 :vxlan
        20 :veth
        21 :macsec
        22 :dummy
        23 :ppp
        24 :ovs-interface
        25 :ovs-port
        26 :ovs-bridge
        27 :wpan
        28 :6lowpan
        29 :wireguard
        30 :wifi-p2p})

(local ignored-device-types
       {:generic true
        :bridge true
        :veth true})

(fn ignore-device?
  [device]
  (->> device.DeviceType
       (. device-types)
       (. ignored-device-types)))

(fn device-unavailable?
  [device]
  (->> device.State
       (. device-states)
       (= :unavailable)))

(fn create-dbus-properties
  [path]
  (: dbus.Proxy :new {:bus dbus.Bus.SYSTEM
                      :name "org.freedesktop.NetworkManager"
                      :interface "org.freedesktop.DBus.Properties"
                      :path path}))

(fn create-network-manager
  [path]
  (: dbus.Proxy :new {:bus dbus.Bus.SYSTEM
                      :name "org.freedesktop.NetworkManager"
                      :interface "org.freedesktop.NetworkManager"
                      :path path}))

(fn create-device
  [path]
  (: dbus.Proxy :new {:bus dbus.Bus.SYSTEM
                      :name "org.freedesktop.NetworkManager"
                      :interface "org.freedesktop.NetworkManager.Device"
                      :path path}))

(fn create-wireless-device
  [path]
  (: dbus.Proxy :new {:bus dbus.Bus.SYSTEM
                      :name "org.freedesktop.NetworkManager"
                      :interface "org.freedesktop.NetworkManager.Device.Wireless"
                      :path path}))

(fn create-access-point
  [path]
  (: dbus.Proxy :new {:bus dbus.Bus.SYSTEM
                      :name "org.freedesktop.NetworkManager"
                      :interface "org.freedesktop.NetworkManager.AccessPoint"
                      :path path}))

(fn normalise-device
  [device]
  (let [device-state (. device-states device.State)
        device-type  (. device-types device.DeviceType)
        ap (when (and (= device-type :wifi)
                      (= device-state :activated))
             (-?> device.object_path
                  (create-wireless-device)
                  (. :ActiveAccessPoint)
                  (create-access-point)))
        result {:interface (.. "" device.Interface)
                :state device-state
                :type device-type}]
    (when ap
      (tset result :ssid (fu.bytes->string ap.Ssid))
      (tset result :strength ap.Strength))
    result))

{:create-device create-device
 :create-network-manager create-network-manager
 :normalise-device normalise-device
 :create-dbus-properties create-dbus-properties
 :ignore-device? ignore-device?
 :device-unavailable? device-unavailable?}
