(local table table)
(local pairs pairs)
(local next next)
(local type type)
(local string string)

(fn number?
  [x]
  (= (type x) "number"))

(fn string?
  [x]
  (= (type x) "string"))

(fn table?
  [x]
  (= (type x) "table"))

(fn userdata?
  [x]
  (= (type x) "userdata"))

(fn inc
  [i]
  (+ i 1))

(fn dec
  [i]
  (- i 1))

(fn iter->table
  [it]
  (let [t {}]
    (each [k v it]
      (tset t k v))
    t))

(fn map
  [f tbl]
  (let [r {}]
    (each [k v (pairs tbl)]
      (tset r k (f v)))
    r))

(fn filter
  [f tbl]
  (let [r {}]
    (each [k v (pairs tbl)]
      (when (f v)
        (tset r k v)))
    r))

(fn remove
  [f tbl]
  (let [r {}]
    (each [k v (pairs tbl)]
      (when (not (f v))
        (tset r k v)))
    r))

(fn keys
  [tbl]
  (let [r {}]
    (each [k v (pairs tbl)]
      (table.insert r k))
    r))

(fn vals
  [tbl]
  (let [r {}]
    (each [k v (pairs tbl)]
      (table.insert r v))
    r))

(fn first
  [tbl]
  (let [(_ v) (next tbl)]
    v))

(fn second
  [tbl]
  (let [(k v1) (next tbl)
        (_ v2) (next tbl k)]
    v2))

(fn nth
  [n tbl]
  (var n n)
  (var k nil)
  (while (> n 0)
    (set k (next tbl k))
    (set n (dec n)))
  (let [(_ v) (next tbl k)]
    v))

(fn join
  [sep tbl]
  (let [[sep tbl] (if tbl [sep tbl] ["" sep])] ;; sep is optional
    (-> tbl
        (vals) ;; table.concat does not work with non-contiguous keys
        (table.concat (or sep "")))))

(fn range
  [from to step]
  (let [step (if (number? step) step 1)
        [from to] (if (number? to)
                      [from to]
                      [0 from])
        r {}]
    ;; TODO: (assert (< from to) "from must be less than to")
    (for [i from to step]
      (table.insert r i))
    r))

;; (fn find
;;   [f tbl]
;;   (var k nil)
;;   (var v nil)
;;   (while (or (= nil v)
;;              (not (f v)))
;;   ;;   (local (k v) (next tbl k))
;;   )
;;   v)

(fn capitalize
  [str]
  (: str :gsub "^%l" string.upper))

(fn seconds->duration
  [secs]
  (if (> secs 3600)
      (string.format "%.1f hrs" (/ secs 3600))
      (> secs 60)
      (string.format "%.1f mins" (/ secs 60))
      ;; else
      (string.format "%.1f secs" secs)))

(fn bytes->string
  [bytes]
  (->> bytes (map string.char) (join)))

{:number? number?
 :string? string?
 :table? table?
 :userdata? userdata?
 :inc inc
 :dec dec
 :iter->table iter->table
 :map map
 :filter filter
 :remove remove
 :keys keys
 :vals vals
 :first first
 :second second
 :nth nth
 :join join
 :range range
 ;; :find find
 :capitalize capitalize
 :seconds->duration seconds->duration
 :bytes->string bytes->string
 }
