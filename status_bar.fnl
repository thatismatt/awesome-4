(local awful (require "awful"))
(local wibox (require "wibox"))
(local upower (require "upower"))
(local nm (require "nm"))
(local fu (require "fennel_utils"))

(fn icon-file
  [...]
  (string.format "/home/matt/Pictures/material-design-icons/%s/1x_web/ic_%s_white_18dp.png" ...))

(fn icon-widget
  [...]
  (wibox.widget.imagebox (icon-file ...)))

(fn two-line-textbox []
  (let [line-1 (wibox.widget.textbox "Loading...")
        line-2 (wibox.widget.textbox "Loading...")]
    (fu.map #(tset $ :font "Liberation Sans 8") [line-1 line-2])
    {:container (wibox.container.margin
                 (wibox.layout.fixed.vertical line-1 line-2)
                 0 0 2 2)
     :set-text (fn [text-1 text-2]
                 (set line-1.markup text-1)
                 (set line-2.markup text-2))}))

(fn icon+textbox
  [text ...]
  (let [textbox (wibox.widget.textbox text)
        icon (icon-widget ...)
        container (wibox.layout.fixed.horizontal
                   (wibox.container.margin icon 5 5 0 0)
                   textbox)]
    {:textbox textbox
     :icon icon
     :container container}))

(fn system-widget
  []
  (let [icon (icon-widget "places" "all_inclusive")
        at-textbox (wibox.widget.textbox "Loading...")
        os-textbox (two-line-textbox)
        info {}
        on-info (fn [k v]
                  (tset info k v)
                  (set at-textbox.text (.. info.user "@" info.host))
                  (os-textbox.set-text info.description (fu.capitalize info.codename)))]
    (awful.spawn.easy_async "whoami"   #(on-info :user (string.gsub $ "%s" "")))
    (awful.spawn.easy_async "hostname" #(on-info :host (string.gsub $ "%s" "")))
    (awful.spawn.with_line_callback
     "lsb_release -a" {:stdout #(let [(k v) (string.match $ "^(.*):%s(.*)$")]
                                  (on-info (string.lower k) v))})
    (wibox.layout.fixed.horizontal
     (wibox.container.margin
      (wibox.layout.fixed.horizontal
       (wibox.container.margin icon 5 5 0 0)
       at-textbox)
      5 5 5 5)
     os-textbox.container)))

(fn battery-widget
  []
  (let [battery (icon+textbox "Loading..." "device" "battery_unknown")
        time-to-textbox (two-line-textbox)
        device (upower.create-device "/org/freedesktop/UPower/devices/DisplayDevice")
        update-fn #(let [{: state : percentage
                          : time-to-empty : time-to-full} (upower.normalise-device device)
                         charge-level (if (= state :empty) "empty"
                                          (<= percentage 20) 20
                                          (<= percentage 30) 30
                                          (<= percentage 50) 50
                                          (<= percentage 60) 60
                                          (<= percentage 80) 80
                                          (<= percentage 90) 90
                                          "full")
                         image (icon-file "device" (fu.join "_" ["battery"
                                                                 (when (or (= state :charging)
                                                                           (= state :full)) "charging")
                                                                 charge-level]))]
                     (set battery.textbox.markup (string.format "%.0f%%" percentage))
                     (if (= state :charging)    (time-to-textbox.set-text
                                                 (fu.seconds->duration time-to-full)
                                                 "until full")
                         (= state :discharging) (time-to-textbox.set-text
                                                 (fu.seconds->duration time-to-empty)
                                                 "until empty")
                         (time-to-textbox.set-text "" ""))
                     (set battery.icon.image image))]
    (update-fn)
    (: device :on_properties_changed update-fn)
    (wibox.layout.fixed.horizontal
     (wibox.container.margin
      battery.container
      5 5 5 5)
     time-to-textbox.container)))

(fn network-widget
  []
  (let [;; TODO: merge this two together
        wifi (icon+textbox "Loading..." "device" "network_wifi")
        ethernet (icon+textbox "Loading..." "social" "public")
        vpn (icon+textbox "" "action" "lock")
        nm-properties (nm.create-dbus-properties "/org/freedesktop/NetworkManager")
        network-manager (nm.create-network-manager "/org/freedesktop/NetworkManager")
        update-fn #(let [device-data (->> (: nm-properties :GetDevices)
                                          (fu.map nm.create-device)
                                          (fu.remove nm.ignore-device?)
                                          (fu.map nm.normalise-device)
                                          (fu.key-by #(. $ :type)))]
                     (let [state (or (-?> device-data (. :ethernet) (. :state))
                                     "[unknown]")]
                       (set ethernet.container.visible (= state :activated))
                       (set ethernet.textbox.text (fu.capitalize state)))
                     (let [{: state : ssid : strength} (or (. device-data :wifi) {})
                           strength-level (if (not= state :activated) "off"
                                              (<= strength 20) "0_bar"
                                              (<= strength 40) "1_bar"
                                              (<= strength 60) "2_bar"
                                              (<= strength 80) "3_bar"
                                              "4_bar")]
                       (set wifi.textbox.text
                            (if (= state :activated) (.. ssid " " strength "%")
                                state (fu.capitalize state)
                                "[unknown]"))
                       (set wifi.icon.image (icon-file "device" (.. "signal_wifi_" strength-level)))
                       (set wifi.active? (= state :activated)))
                     (set wifi.container.visible (or (-?> device-data (. :wifi) (. :state) (= :activated))
                                                     (not (-?> device-data (. :ethernet) (. :state) (= :activated)))))
                     (set vpn.container.visible
                          (-?> device-data (. :tun) (. :state) (= :activated))))
        toggle-wifi-fn #(awful.spawn (.. "nmcli radio wifi " (if wifi.active? "off" "on")) false)]
    ;; TODO: add tooltip
    ;; (awful.tooltip {:objects [wifi.textbox]
    ;;                 :timer_function #(os.date "Today is %A %B %d %Y\\nThe time is %T")})
    (update-fn)
    (: network-manager :on_properties_changed update-fn)
    (: wifi.container :buttons (awful.button {} 1 toggle-wifi-fn))
    (wibox.container.margin
     (wibox.layout.fixed.horizontal
      ethernet.container
      wifi.container
      vpn.container)
     5 5 5 5)))

(fn mpc-button
  [image command]
  (doto (icon-widget "av" image)
    (: :buttons (awful.button {} 1 #(awful.spawn (.. "mpc " command) false)))))

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
