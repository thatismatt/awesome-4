(local awful (require "awful"))
(local wibox (require "wibox"))
(local upower (require "upower"))

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

(fn init
  [screen]
  (let [bar (awful.wibar {:position "bottom"
                          :screen screen})]
    (: bar :setup
       {:layout wibox.layout.align.horizontal
        1 (battery-widget)})))

{:init init}
