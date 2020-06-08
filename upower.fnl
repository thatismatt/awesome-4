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

(fn normalise-device
  [device]
  ;; (fu.map #(utils.log $ (. device $))
  ;;         ["Type" "Energy" "Model" "EnergyEmpty" "TimeToFull" "WarningLevel" "Luminosity" "EnergyFull"
  ;;          "Percentage" "IconName" "HasHistory" "Temperature" "NativePath" "Serial" "Voltage" "Vendor"
  ;;          "IsRechargeable" "UpdateTime" "EnergyFullDesign" "PowerSupply" "IsPresent" "BatteryLevel"
  ;;          "Online" "HasStatistics" "Technology" "Capacity" "State" "TimeToEmpty" "EnergyRate" ])
  (let [device-state (. device-states device.State)]
    {:state device-state
     :time-to-full device.TimeToFull
     :time-to-empty device.TimeToEmpty
     :percentage device.Percentage}))

{:create-device create-device
 :normalise-device normalise-device}
