(local awful (require "awful"))
(local wibox (require "wibox"))
(local upower (require "upower"))
(local nm (require "nm"))
(local fu (require "fennel_utils"))

(fn icon-widget
  [...]
  (wibox.widget.imagebox
    (string.format "/home/matt/Pictures/material-design-icons/%s/1x_web/ic_%s_white_18dp.png" ...)))


(fn system-widget
  []
  (let [textbox (wibox.widget.textbox "Loading...")
        info {}
        on-info (fn [k v]
                  (tset info k v)
                  (set textbox.text
                       (string.format "%s@%s (%s %s)"
                                      info.user info.host info.description info.codename)))]
    (awful.spawn.easy_async "whoami"   #(on-info :user (string.gsub $ "%s" "")))
    (awful.spawn.easy_async "hostname" #(on-info :host (string.gsub $ "%s" "")))
    (awful.spawn.with_line_callback
     "lsb_release -a" {:stdout #(let [(k v) (string.match $ "^(.*):%s(.*)$")]
                                  (on-info (string.lower k) v))})
    (wibox.container.margin
     textbox
     5 5 5 5)))

(fn battery-widget
  []
  (let [icon (icon-widget "device" "battery_full")
        textbox (wibox.widget {:markup "Loading..."
                               :widget wibox.widget.textbox})
        device (upower.create-device "/org/freedesktop/UPower/devices/DisplayDevice")
        update-fn #(set textbox.text (upower.device->label device))]
    (update-fn)
    (: device :on_properties_changed update-fn)
    (wibox.container.margin (wibox.layout.fixed.horizontal
                             (wibox.container.margin icon 5 5 0 0)
                             textbox)
                            5 5 5 5)))

(fn network-widget
  []
  (let [icon (icon-widget "device" "network_wifi")
        textbox (wibox.widget {:markup "Loading..."
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
                                          (fu.join " | ")))]
    (update-fn)
    (each [_ device (ipairs devices)]
      (: device :on_properties_changed update-fn))
    (wibox.container.margin (wibox.layout.fixed.horizontal
                             (wibox.container.margin icon 5 5 0 0)
                             textbox)
                            5 5 5 5)))

(fn mpc-button
  [image command]
  (let [img (icon-widget "av" image)]
    (: img :buttons (awful.button {} 1 #(awful.spawn (.. "mpc " command) false)))
    img))

(fn mpc-widget
  []
  (wibox.container.margin
   (wibox.layout.fixed.horizontal
    (mpc-button "skip_previous" "prev")
    (mpc-button "fast_rewind"   "seek -60")
    (mpc-button "play_arrow"    "toggle")
    (mpc-button "fast_forward"  "seek +60")
    (mpc-button "skip_next"     "next"))
   5 5 5 5))

(fn init
  [screen]
  (let [bar (awful.wibar {:position "bottom"
                          :screen screen})]
    (: bar :setup
       {:layout wibox.layout.align.horizontal
        :expand :inside ;; right align mpc widget
        1 (system-widget)
        2 {:layout wibox.layout.align.horizontal
           :expand :outside ;; center battery & network widgets
           2 (wibox.layout.fixed.horizontal
              (battery-widget)
              (network-widget))}
        3 (mpc-widget)})))

{:init init}
