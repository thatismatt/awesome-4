(local awful (require "awful"))
(local gears (require "gears"))
(local upower (require "upower"))
(local nm (require "nm"))
(local string string)

(local fu (require "fennel_utils"))
(local utils (require "utils"))

(fn battery-format
  [battery]
  (let [state (. battery :state)
        percentage (. battery :percentage)
        seconds-remaining (if (= state "charging")      (. battery :time-to-full)
                              (= state "discharging")   (. battery :time-to-empty)
                              (= state "fully-charged") 0)
        time-remaining (if (> seconds-remaining 3600)
                           (string.format "(%.1f hrs)" (/ seconds-remaining 3600))
                           (> seconds-remaining 60)
                           (string.format "(%.1f mins)" (/ seconds-remaining 60))
                           (> seconds-remaining 0)
                           (string.format "(%.1f secs)" seconds-remaining)
                           "")]
    (string.format "Battery: %s %s%% %s"
                   state percentage time-remaining)))

(fn battery-widget
  []
  (let [textbox (wibox.widget {:markup "Loading..."
                               :widget wibox.widget.textbox})
        display (fn []
                  (->> (upower.battery-info)
                       (battery-format)
                       (set textbox.text)))]
    (display)
    (gears.timer
     {:autostart true
      :timeout 30
      :callback display})
    (wibox.container.margin textbox
                            5 5 5 5)))

(fn network-format
  [data]
  (let [connectivity (. data :connectivity)
        network-info (. data :network-info)]
    (.. "Network: "
        (if (= connectivity "FULL")
            ""
            (.. connectivity " "))
        (->> network-info
             (fu.map (fn [x] (.. (. x :interface)
                                 " "
                                 (. x :connection))))
             (fu.join " ")))))

(fn network-widget
  []
  (let [textbox (wibox.widget {:markup "Loading..."
                               :widget wibox.widget.textbox})
        display (fn []
                  (->> {:network-info (nm.network-info)
                        :connectivity (nm.connectivity)}
                       (network-format)
                       (set textbox.text)))]
    (display)
    (gears.timer
     {:autostart true
      :timeout 30
      :callback display})
    (wibox.container.margin textbox
                            5 5 5 5)))

(fn init
  [screen]
  (let [wibox-bottom (awful.wibar {:position "bottom"
                                   :screen screen})]
    (: wibox-bottom :setup
       {:layout wibox.layout.align.horizontal
        1 (battery-widget)
        2 (network-widget)})))

{:init init}
