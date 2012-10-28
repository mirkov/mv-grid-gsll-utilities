(asdf:defsystem mv-grid+gsll-utilities
  :components
  ((:module "setup"
	    :pathname #p"./"
	    :components ((:file "mv-grid+gsll-package-def")))
   (:module "tabular-data"
	    :pathname #p"./"
	    :depends-on ("setup")
	    :components ((:file "tabular-data"))))
  :depends-on (:alexandria
	       :gsll
	       :antik
	       :mv-grid-utils))
