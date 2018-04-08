(in-package #:python3-cffi.test)

(addtest (burgled-batteries)
  types-have-refcnts-and-are-types
  (let (type-vars)
    (do-external-symbols (s '#:cpython3 type-vars)
      (let ((symbol-name (symbol-name s)))
        (when (and (string= '#:+ symbol-name :end2 1)
                   (string= '#:.type+ symbol-name :start2 (- (length symbol-name) 6)))
          (push s type-vars))))
    (loop :for type-var :in type-vars
          :do (assert (plusp (cpython3::%object.refcnt (eval type-var)))
                      ()
                      "Python type ~S does not have a positive reference count."
                      type-var)
              (assert (string= "<type '" (cpython3:object.str (eval type-var)) :end2 7)
                      ()
                      "Python type ~S is not stringified as a type."
                      type-var))))

(addtest (burgled-batteries)
  apply-min
  (let ((nums (alexandria:shuffle (list 1 2 3 4 5 6 7 8 9 10))))
    (burgled-batteries::with-cpython-pointer (min-fn (burgled-batteries:run* "min"))
      (assert (= (apply #'burgled-batteries:apply min-fn nums)
                 (apply #'min nums))
              ()
              "Something seems to be wrong with APPLY.  Have types been switched again?"))))

(eval-when (:compile-toplevel :load-toplevel)
  (burgled-batteries:startup-python))

(addtest (burgled-batteries)
  defpyfun-max
  (burgled-batteries:defpyfun ("max" pymax) (&rest args))
  (let ((nums (alexandria:shuffle (list 1 2 3 4 5 6 7 8 9 10))))
    (assert (= (pymax nums) (apply #'max nums))
            ()
            "Either MAX is broken or DEFPYFUN is having issues.")))

(eval-when (:compile-toplevel :load-toplevel)
  (burgled-batteries:shutdown-python))
