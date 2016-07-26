
(cl:in-package :asdf)

(defsystem "turtle-msg"
  :depends-on (:roslisp-msg-protocol :roslisp-utils )
  :components ((:file "_package")
    (:file "modeMsg" :depends-on ("_package_modeMsg"))
    (:file "_package_modeMsg" :depends-on ("_package"))
  ))