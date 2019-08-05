(local dbus (require "dbus_proxy"))
(local fu (require "fennel_utils"))

(local device-states
       {1 :charging
        2 :discharging
        3 :empty
        4 :full})

(fn create-device
  [path]
  (: dbus.Proxy :new {:bus dbus.Bus.SYSTEM
                      :name "org.freedesktop.UPower"
                      :interface "org.freedesktop.UPower.Device"
                      :path path}))

(fn device->label
  [device]
  (let [device-state (. device-states device.State)
        details (match device-state
                  :charging    (.. (fu.seconds->duration device.TimeToFull) " to full")
                  :discharging (.. (fu.seconds->duration device.TimeToEmpty) " to empty")
                  :full        "full"
                  :empty       "empty")]
    (.. "Battery: " device.Percentage "% (" details ")")))

{:create-device create-device
 :device->label device->label}
