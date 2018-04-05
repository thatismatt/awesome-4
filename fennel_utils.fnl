(local table table)
(local pairs pairs)
(local next next)

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

(defn join
  [sep tbl]
  (let [[sep tbl] (if tbl [sep tbl] ["" sep])] ;; sep is optional
    (-> tbl
        (vals) ;; table.concat does not work with non-contiguous keys
        (table.concat (or sep "")))))

;; (defn find
;;   [f tbl]
;;   (var k nil)
;;   (var v nil)
;;   (while (or (= nil v)
;;              (not (f v)))
;;   ;;   (local (k v) (next tbl k))
;;   )
;;   v)

{:iter->table iter->table
 :map map
 :filter filter
 :vals vals
 :first first
 :join join
 ;; :find find
 }
