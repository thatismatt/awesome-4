(local lgi (require "lgi"))
(local nm-glib (lgi.require "NM")) ;; https://developer.gnome.org/libnm/1.0/
;; see: https://github.com/NetworkManager/NetworkManager/tree/master/examples/lua/lgi
(local fu (require "fennel_utils"))

(local client (nm-glib.Client))

(fn network-info
  []
  (->> (: client :get_devices)
       (fu.map (fn [d]
                 (let [connection (: d :get_active_connection)]
                   {:interface (. d :interface)
                    :device-type (. d :device-type)
                    :state (. d :state)
                    :connection (when connection
                                  (: connection :get_id))})))
       (fu.filter (fn [d]
                    (let [dt (. d :device-type)]
                      (or (= dt :WIFI)
                          (= dt :ETHERNET)))))
       (fu.filter (fn [d]
                    (= (. d :state) :ACTIVATED)))))

;; {
;;  state = "ACTIVATED"
;;  interface = "wlp6s0"
;;  device-type = "WIFI"
;; }

(fn connectivity
  []
  (: client :get_connectivity))

{:network-info network-info
 :connectivity connectivity}
