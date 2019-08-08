(local awful (require "awful"))
(local wibox (require "wibox"))
(local upower (require "upower"))
(local nm (require "nm"))
(local fu (require "fennel_utils"))

(fn battery-widget
  []
  (let [textbox (wibox.widget {:markup "Loading..."
                               :widget wibox.widget.textbox})
        device (upower.create-device "/org/freedesktop/UPower/devices/DisplayDevice")
        update-fn #(set textbox.text (upower.device->label device))]
    (update-fn)
    (: device :on_properties_changed update-fn)
    (wibox.container.margin textbox
                            5 5 5 5)))

(fn network-widget
  []
  (let [textbox (wibox.widget {:markup "Loading..."
                               :widget wibox.widget.textbox})
        manager (nm.create-dbus-properties "/org/freedesktop/NetworkManager")
        ;; NOTE: we don't want to display the generic device, but if we don't add the listener the
        ;;       wifi property changes aren't signalled, see below for where the genereic device is
        ;;       filtered out
        devices (->> (: manager :GetDevices)
                     (fu.map nm.create-device)
                     (fu.remove nm.ignore-device?))
        update-fn #(set textbox.text (->> devices
                                          (fu.remove nm.generic-device?)
                                          (fu.remove nm.device-unavailable?)
                                          (fu.map nm.device->label)
                                          (fu.join " | ")
                                          (.. "Network: ")))]
    (update-fn)
    (each [_ device (ipairs devices)]
      (: device :on_properties_changed update-fn))
    (wibox.container.margin textbox
                            5 5 5 5)))

(fn init
  [screen]
  (let [bar (awful.wibar {:position "bottom"
                          :screen screen})]
    (: bar :setup
       {:layout wibox.layout.align.horizontal
        1 (battery-widget)
        2 (network-widget)})))

{:init init}
