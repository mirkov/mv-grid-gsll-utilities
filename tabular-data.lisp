;; Mirko Vukovic
;; Time-stamp: <2012-07-11 17:15:46 tabular-data.lisp>
;; 
;; Copyright 2011 Mirko Vukovic
;; Distributed under the terms of the GNU General Public License
;; 
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(in-package :mv-grid+gsll)

;; tabular-data class stores multi-dimensional arrays and provides
;; facilities fore retreival and interpolation
(export '(tabular-data
	  table-data table-column data-documentation table-rank
	  table-dimensions table-rows table-columns table-pages
	  table-elements table-column-names
	  make-table
	  init-table-interp interp-table))

(defclass tabular-data ()
  ((source :reader data-source
	   :initarg :data-source
	   :documentation "Source of data: file or some other identifiable
procedure")
   (data :initarg :data
	 :reader table-data
	 :documentation "The data itself.  Must be a native lisp array
or grid vector or array")
   (documentation :initarg :data-documentation
		  :initform nil
		  :reader data-documentation
		  :documentation "String describing the data")
   (rank :reader table-rank
	 :documentation "Return the number of dimensions of the table")
   (dimensions :reader table-dimensions
	       :documentation "List of table dimensions")
   (rows :reader table-rows)
   (columns :reader table-columns
	    :initform nil)
   (pages :reader table-pages
	  :initform nil
	  :documentation "For three-dimensional tables, return the 
length of the third dimension")
   (elements :reader table-elements)
   (column-names :reader table-column-names)
   (interpolation-data :documentation
		       "Store data for table interpolation"))
  (:documentation "Store table `data' is obtained from an external
`source' (typically a file or some other numerical procedure.

This class does not generate the data in any way (such as reading it
or creating it by some numerical procedure.

Class provides facilities to return basic information on the table

Methods on this object provide lookup and interpolation methods."))

  
(defmethod print-object ((self tabular-data) stream)
  (print-unreadable-object (self stream :type t :identity t)))

(defmethod describe-object ((self tabular-data) stream)
  (format stream "Tabular data~%")
  (format stream "Data source: ~a~%" (data-source self))
  (format stream "The table has ~a dimensions of length ~a~%"
	  (table-rank self)
	  (table-dimensions self)))

(defmethod initialize-instance :after ((self tabular-data)
				       &key data-source data
				       data-documentation)
  "This method deals with storing the data.  Setting up interpolation tables
is done separately, since there may be multiple ways to do that"
  (assert (or (typep data 'array)
	      (typep data 'foreign-array))
	  () "Data type ~a is not of type array or foreign array"
	  (type-of data))
  (with-slots (source data rank dimensions rows columns pages elements) self
    (setf data  data
	  dimensions  (grid:dimensions data)
	  rank (grid:grid-rank data)
	  elements (loop for d in dimensions
		      with p = 1
		      do (setf p (* p d))
		      finally (return p)))
    (when data-source (setf source data-source))
    (when data-documentation
      (setf (slot-value self 'documentation) data-documentation))
    (setf rows (first dimensions))
    (when (> rank 1) (setf columns (second dimensions)))
    (when (> rank 2) (setf pages (third dimensions)))))

  
(defun make-table (data &optional source documentation)
  (make-instance 'tabular-data :data data :data-source source
		 :data-documentation documentation))

(defun make-test-table ()
  (let* ((file "test.dat")
	 (csv-parser:*field-separator* #\Space)
	 (*array-type* 'grid::foreign-array)
	 (table (with-input-from-file (stream file)
		  (make-table
		   (mv-grid:read-grid '(nil 7) stream :csv :eof-value :eof
				      :type 'double-float)
		   file "foo"))))
    table))

(define-test make-tabular-data
  (let ((table (make-test-table))
	(assert-equal '(82 7) (table-dimensions table))
	(assert-equal 2 (table-rank table))
	(assert-equal (* 82 7) (table-elements table))
	(assert-equal "test.dat" (data-source table))
	(assert-equal 82 (table-rows table))
	(assert-equal 7 (table-columns table))
	(assert-true (not (table-pages table))))))

  
		



(defmethod init-table-interp ((self tabular-data)
			       &optional (interpolation-type
					  gsll:+cubic-spline-interpolation+))
  (setf (slot-value self 'interpolation-data)
	(make-array 8))
  (let ((x (grid:column (table-data self) 0)))
    (dotimes (i (table-columns self))
      (setf (aref (slot-value self 'interpolation-data) i)
	    (gsll:make-spline interpolation-type
			      x (grid:column (table-data self) i))))))

(defmethod interp-table ((self tabular-data) x-value column-index)
  (gsll:evaluate (aref
		  (slot-value self 'interpolation-data)
		  column-index)
		 x-value))

(defmethod table-column ((self tabular-data) column-index)
  (grid:column (table-data self) column-index))

(define-test table-interpolation
  ;; I test the table spline interpolation by interpolating a column
  ;; against itself.
  (let* ((table (make-test-table)))
    (init-table-interp table)
    (assert-numerical-equal
     1.01d0
     (interp-table table 1.01d0 0))))


  