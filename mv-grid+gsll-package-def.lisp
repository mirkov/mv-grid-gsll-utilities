;; Mirko Vukovic
;; Time-stamp: <2012-10-27 22:45:40Eastern Daylight Time mv-grid+gsll-package-def.lisp>
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

(defpackage :mv-grid+gsll
  (:nicknames :mv-grid+gsll)
  (:use :cl :mv-grid :lisp-unit)
  (:shadow :lisp-unit :norm)
  (:import-from :alexandria :with-input-from-file)
  (:documentation "foo"))

(antik:make-user-package :mv-grid+gsll)
