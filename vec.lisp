;;;; By Nikodemus Siivola <nikodemus@random-state.net>, 2009.
;;;;
;;;; Permission is hereby granted, free of charge, to any person
;;;; obtaining a copy of this software and associated documentation files
;;;; (the "Software"), to deal in the Software without restriction,
;;;; including without limitation the rights to use, copy, modify, merge,
;;;; publish, distribute, sublicense, and/or sell copies of the Software,
;;;; and to permit persons to whom the Software is furnished to do so,
;;;; subject to the following conditions:
;;;;
;;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;;;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;;;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
;;;; IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
;;;; CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
;;;; TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
;;;; SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

(in-package :sb-cga)

;;;; PREDICATES AND SUBTYPES

(declaim (ftype (sfunction (t) boolean) vecp)
         (inline vecp))
(defun vecp (object)
  "Return true if OBJECT is a VEC.."
  (typep object 'vec))

(declaim (ftype (sfunction (t) boolean) pointp)
         (inline pointp))
(defun pointp (object)
  "Return true if OBJECT is a point."
  (and (vecp object) (= 1.0 (aref object 3))))

(deftype point ()
  "Point type: subtype of VEC consisting of those VECs whose 4th element is
1.0."
  `(satisfies pointp))

(declaim (ftype (sfunction (t) boolean) vector3p)
         (inline vector3p))
(defun vector3p (object)
  "Return true if OBJECT is a 3D vector."
  (and (vecp object) (= 0.0 (aref object 3))))

(deftype vector3 ()
  "3D vector type: subtype of VEC consisting of those VECs whose 4th element
is 0.0."
  `(satisfies vector3p))

;;;; PRETTY PRINTING

(defun pprint-vec (stream vec)
  (print-unreadable-object (vec stream :type nil :identity nil)
    (cond ((vector3p vec)
           (format stream "Vector3 ~s, ~s, ~s"
                   (aref vec 0)
                   (aref vec 1)
                   (aref vec 2)))
          ((pointp vec)
           (format stream "Point ~s, ~s, ~s"
                   (aref vec 0)
                   (aref vec 1)
                   (aref vec 2)))
          (t
           (format stream "Vec ~s, ~s, ~s, ~s"
                   (aref vec 0)
                   (aref vec 1)
                   (aref vec 2)
                   (aref vec 3)))))
  vec)
(set-pprint-dispatch 'vec 'pprint-vec)

;;;; CONSTRUCTORS

(declaim (ftype (sfunction () vec) alloc-vec)
         (inline alloc-vec))
(defun alloc-vec ()
  "Allocate a zero-initialized VEC."
  (make-array 4 :element-type 'single-float))

(declaim (ftype (sfunction (single-float single-float single-float single-float) vec) vec)
         (inline vec))
(defun vec (a b c d)
  "Allocate 4D vector [A, B, C, D]."
  (make-array 4 :element-type 'single-float :initial-contents (list a b c d)))

(declaim (ftype (sfunction (single-float single-float single-float) vec) point)
         (inline point))
(defun point (x y z)
  "Allocate point \(X,Y,Z)."
  (vec x y z 1.0))

(declaim (ftype (sfunction (single-float single-float single-float) vec) vector3)
         (inline vector3))
(defun vector3 (a b c)
  "Allocate 3D vector [A,B,C]."
  (vec a b c 0.0))

;;;; CONVERSIONS

(declaim (ftype (sfunction (point) vec) point->vector3)
         (inline point->vector3))
(defun point->vector3 (point)
  "Return 3D vector corresponding to coordinates of POINT. May signal a TYPE-ERROR
if POINT is not a proper point with 4th element 1.0"
  (vector3 (aref point 0) (aref point 1) (aref point 2)))

(declaim (ftype (sfunction (vector3) vec) vector3->point)
         (inline vector3->point))
(defun vector3->point (location)
  "Return point for corresponding to the 3D vector LOCATION. May signal a TYPE-ERROR
if LOCATION is not a proper 3D vector with 4th element 0.0"
  (point (aref location 0) (aref location 1) (aref location 2)))

;;;; COMPARISON

(declaim (ftype (sfunction (vec vec) boolean) vec=)
         (inline vec=))
(defun vec= (a b)
  "Return true if VEC A and VEC B are elementwise identical."
  (sb-cga-vm:%vec= a b))

;;;; COPYING

(declaim (ftype (sfunction (vec) vec) copy-vec)
         (inline copy-vec))
(defun copy-vec (vec)
  "Allocate a fresh copy of VEC."
  (%copy-vec (alloc-vec) vec))

;;;; ARITHMETIC

(declaim (ftype (sfunction (vec vec) vec) vec+)
         (inline vec+))
(defun vec+ (a b)
  "Add VEC A and VEC B, return result as a freshly allocated VEC."
  (%vec+ (alloc-vec) a b))

(declaim (ftype (sfunction (vec vec) vec) vec-)
         (inline vec-))
(defun vec- (a b)
  "Substract VEC B from VEC A, return result as a freshly allocated VEC."
  (%vec- (alloc-vec) a b))

(declaim (ftype (sfunction (vec single-float)) vec*)
         (inline vec*))
(defun vec* (a f)
  "Multiply VEC A with single-float F, return result as a freshly allocated
VEC."
  (%vec* (alloc-vec) a f))

(declaim (ftype (sfunction (vec single-float) vec) vec/)
         (inline vec/))
(defun vec/ (a f)
  "Divide VEC A by single-float F, return result as a freshly allocated VEC."
  (%vec/ (alloc-vec) a f))

(declaim (ftype (sfunction (vec vec) single-float))
         (inline dot-product))
(defun dot-product (a b)
  "Compute dot product VEC A and VEC B."
  (sb-cga-vm:%dot-product a b))

(declaim (ftype (sfunction (vec vec) vec) hadamard-product)
         (inline hadamard-product))
(defun hadamard-product (a b)
  "Compute hadamard product (elementwise product) of VEC A and VEC B,
return result as a freshly allocated VEC."
  (%hadamard-product (alloc-vec) a b))

(declaim (ftype (sfunction (vec) single-float) vec-length)
         (inline vec-length))
(defun vec-length (a)
  "Length of VEC A. Note that the results are nonsensical for points: use
first POINT->VECTOR3 if you need the distance of a point from origin."
  (sb-cga-vm:%vec-length a))

(declaim (ftype (sfunction (vec) vec))
         (inline normalize))
(defun normalize (a)
  "Normalize VEC A, return result as a freshly allocated VEC."
  (%normalize (alloc-vec) a))

(declaim (ftype (sfunction (vec vec single-float) vec) vec-lerp)
         (inline vec-lerp))
(defun vec-lerp (a b f)
  "Linear interpolate VEC A and VEC B using single-float F as the
interpolation factor, return result as a freshly allocated VEC."
  (%vec-lerp (alloc-vec) a b f))

(declaim (ftype (sfunction (vec &rest vec) vec) vec-min)
         (inline vec-min))
(defun vec-min (vec &rest vecs)
  "Elementwise minimum of VEC and VECS, return result as a freshly allocated
VEC."
  (declare (dynamic-extent vecs))
  (let ((result (copy-vec vec)))
    (dolist (vec vecs)
      (macrolet ((dim (n)
                   `(setf (aref result ,n) (min (aref result ,n) (aref vec ,n)))))
        (dim 0)
        (dim 1)
        (dim 2)
        (dim 3)))
    result))

(declaim (ftype (sfunction (vec &rest vec) vec) vec-max)
         (inline vec-max))
(defun vec-max (vec &rest vecs)
  "Elementwise maximum of VEC and VECS, return result as a freshly allocated
VEC."
  (declare (dynamic-extent vecs))
  (let ((result (copy-vec vec)))
    (dolist (vec vecs)
      (macrolet ((dim (n)
                   `(setf (aref result ,n) (max (aref result ,n) (aref vec ,n)))))
        (dim 0)
        (dim 1)
        (dim 2)
        (dim 3)))
    result))

(declaim (ftype (sfunction (vector3 vector3) vec) cross-product)
         (inline cross-product))
(defun cross-product (a b)
  "Cross product of 3D vector A and 3D vector B, return result as a freshly
allocated VEC."
  (declare (type vector a b) (optimize speed))
  (let ((a1 (aref a 0))
        (a2 (aref a 1))
        (a3 (aref a 2))
        (b1 (aref b 0))
        (b2 (aref b 1))
        (b3 (aref b 2)))
    (vector3 (- (* a2 b3) (* a3 b2))
             (- (* a3 b1) (* a1 b3))
             (- (* a1 b2) (* a2 b1)))))


