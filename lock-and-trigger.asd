;;; -*- Mode: LISP; Syntax: COMMON-LISP; Package: CL-USER; Base: 10 -*-
(asdf:defsystem #:lock-and-trigger
  :depends-on (#:xlog
               #:sb-posix)
  :components ((:file "lock-and-trigger")))
