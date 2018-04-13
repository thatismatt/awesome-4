(local table table)
(local pairs pairs)
(local next next)
(local type type)

(defn number?
  [x]
  (= (type x) "number"))

(defn string?
  [x]
  (= (type x) "string"))

(defn table?
  [x]
  (= (type x) "table"))

(defn userdata?
  [x]
  (= (type x) "userdata"))

(defn inc
  [i]
  (+ i 1))

(defn dec
  [i]
  (- i 1))

(defn iter->table
  [it]
  (let [t {}]
    (each [k v it]
      (tset t k v))
    t))

(defn map
  [f tbl]
  (let [r {}]
    (each [k v (pairs tbl)]
      (tset r k (f v)))
    r))

(defn filter
  [f tbl]
  (let [r {}]
    (each [k v (pairs tbl)]
      (when (f v)
        (tset r k v)))
    r))

(defn vals
  [tbl]
  (let [r {}]
    (each [k v (pairs tbl)]
      (table.insert r v))
    r))

(defn first
  [tbl]
  (let [(_ v) (next tbl)]
    v))

(defn second
  [tbl]
  (let [(k v1) (next tbl)
        (_ v2) (next tbl k)]
    v2))

(defn nth
  [n tbl]
  (var n n)
  (var k nil)
  (while (> n 0)
    (set k (next tbl k))
    (set n (dec n)))
  (let [(_ v) (next tbl k)]
    v))

(defn join
  [sep tbl]
  (let [[sep tbl] (if tbl [sep tbl] ["" sep])] ;; sep is optional
    (-> tbl
        (vals) ;; table.concat does not work with non-contiguous keys
        (table.concat (or sep "")))))

(defn range
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

;; (defn find
;;   [f tbl]
;;   (var k nil)
;;   (var v nil)
;;   (while (or (= nil v)
;;              (not (f v)))
;;   ;;   (local (k v) (next tbl k))
;;   )
;;   v)

{:number? number?
 :string? string?
 :table? table?
 :userdata? userdata?
 :inc inc
 :dec dec
 :iter->table iter->table
 :map map
 :filter filter
 :vals vals
 :first first
 :second second
 :nth nth
 :join join
 :range range
 ;; :find find
 }
