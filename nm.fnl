(local lgi (require "lgi"))
(local nm-glib (lgi.require "NM")) ;; https://developer.gnome.org/libnm/1.0/
(local fu (require "fennel_utils"))

(local client (nm-glib.Client))

(defn network-info
  []
  (->> (: client :get_devices)
       (fu.map (fn [d]
                 {:interface (. d :interface)
                  :device-type (. d :device-type)
                  :state (. d :state)}))
       (fu.filter (fn [d]
                    (let [dt (. d :device-type)]
                      (or (= dt :WIFI)
                          (= dt :ETHERNET)))))))

;; {
;;  state = "ACTIVATED"
;;  interface = "wlp6s0"
;;  device-type = "WIFI"
;; }

{:network-info network-info}
