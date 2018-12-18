(local lgi (require "lgi"))
(local upower-glib (lgi.require "UPowerGlib")) ;; https://lazka.github.io/pgi-docs/UPowerGlib-1.0/index.html
(local fu (require "fennel_utils"))

(local client (upower-glib.Client))

(fn battery-info
  []
  (->> (: client :get_devices)
       (fu.map (fn [d]
                 {:kind (-> (. d :kind)
                            (upower-glib.Device.kind_to_string))
                  :state (-> (. d :state)
                             (upower-glib.Device.state_to_string))
                  :percentage (. d :percentage)
                  :time-to-full  (. d :time-to-full)
                  :time-to-empty (. d :time-to-empty)}))
       (fu.filter (fn [d]
                    (-> d (. :kind) (= :battery))))
       (fu.first)))

{:battery-info battery-info}
