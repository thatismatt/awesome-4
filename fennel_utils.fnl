(local fu {})

(fn fu.number?
  [x]
  (= (type x) "number"))

(fn fu.string?
  [x]
  (= (type x) "string"))

(fn fu.table?
  [x]
  (= (type x) "table"))

(fn fu.userdata?
  [x]
  (= (type x) "userdata"))

(fn fu.inc
  [i]
  (+ i 1))

(fn fu.dec
  [i]
  (- i 1))

(fn fu.iter->table
  [it]
  (let [t {}]
    (each [k v it]
      (tset t k v))
    t))

(fn fu.map
  [f tbl]
  (let [r {}]
    (each [k v (pairs tbl)]
      (tset r k (f v)))
    r))

(fn fu.filter
  [f tbl]
  (let [r {}]
    (each [k v (pairs tbl)]
      (when (f v)
        (tset r k v)))
    r))

(fn fu.remove
  [f tbl]
  (let [r {}]
    (each [k v (pairs tbl)]
      (when (not (f v))
        (tset r k v)))
    r))

(fn fu.keys
  [tbl]
  (let [r {}]
    (each [k v (pairs tbl)]
      (table.insert r k))
    r))

(fn fu.vals
  [tbl]
  (let [r {}]
    (each [k v (pairs tbl)]
      (table.insert r v))
    r))

(fn fu.first
  [tbl]
  (let [(_ v) (next tbl)]
    v))

(fn fu.second
  [tbl]
  (let [(k v1) (next tbl)
        (_ v2) (next tbl k)]
    v2))

(fn fu.nth
  [n tbl]
  (var n n)
  (var k nil)
  (while (> n 0)
    (set k (next tbl k))
    (set n (dec n)))
  (let [(_ v) (next tbl k)]
    v))

(fn fu.join
  [sep tbl]
  (let [[sep tbl] (if tbl [sep tbl] ["" sep])] ;; sep is optional
    (-> tbl
        (fu.vals) ;; table.concat does not work with non-contiguous keys
        (table.concat (or sep "")))))

(fn fu.range
  [from to step]
  (let [step (if (fu.number? step) step 1)
        [from to] (if (fu.number? to)
                      [from to]
                      [0 from])
        r {}]
    ;; TODO: (assert (< from to) "from must be less than to")
    (for [i from to step]
      (table.insert r i))
    r))

;; (fn fu.find
;;   [f tbl]
;;   (var k nil)
;;   (var v nil)
;;   (while (or (= nil v)
;;              (not (f v)))
;;   ;;   (local (k v) (next tbl k))
;;   )
;;   v)

(fn fu.key-by
  [f tbl]
  (let [r {}]
    (each [_ v (pairs tbl)]
      (tset r (f v) v))
    r))

(fn fu.capitalize
  [str]
  (string.gsub str "^%l" string.upper))

(fn fu.seconds->duration
  [secs]
  (if (> secs 3600)
      (string.format "%.1f hrs" (/ secs 3600))
      (> secs 60)
      (string.format "%.1f mins" (/ secs 60))
      ;; else
      (string.format "%.1f secs" secs)))

(fn fu.bytes->string
  [bytes]
  (->> bytes (fu.map string.char) (fu.join)))

fu
