;;;; lock-and-trigger.lisp

(defpackage #:lock-and-trigger
  (:use #:cl 
        #:xlog)
  
  (:export 
   #:handler-case-mebbe
   #:reset-trigger-file
   #:trigger-file
   #:trigger-file-hard
   #:create-trigger-file
   #:lockme
   #:unlockme))

(in-package #:lock-and-trigger)

(defparameter *use-handlers* nil)
(defparameter *trigger-file-found* nil)

(defun reset-trigger-file()
  (setf *trigger-file-found* nil))

(defun trigger-file-only (file-name)
  (let* ((pathname (make-pathname :name (concatenate 'string file-name ".trg")))
         (trigger (open pathname :direction :probe)))
    (when trigger
      (delete-file pathname))
    trigger))

(defun trigger-file-hard (file-name)
   (probe-file (make-pathname :name file-name :type "trg")))

(defun trigger-file (file-name &optional (reset nil))
  (if reset (setf *trigger-file-found* (not reset)))
  (let* ((pathname (make-pathname :name (concatenate 'string file-name ".trg")))
         (trigger (open pathname :direction :probe)))
    (when trigger
      (setf *trigger-file-found* (not reset))
      (delete-file pathname))
    (or trigger *trigger-file-found*)))

(defun create-trigger-file(file-name &optional (msg "stop this script"))
;; TODO -- use with-open-file
  (let* ((pathname (make-pathname :name (concatenate 'string file-name ".trg")))
         (trigger (open pathname
                        :direction :output
                        :if-exists :append
                        :if-does-not-exist :create)))
    (write-line msg trigger)
    (close trigger)))

(defun lockme (lockname)
  (xlogf "lockme: locking ~a" lockname)
  (let ((fn (concatenate 'string lockname ",lck"))
        (rv nil))
    (handler-case
        (let ((fd (sb-posix:open fn (logior sb-posix:o-wronly
                                            sb-posix:o-creat) 0)))
          (sb-posix:close fd)
          (setf rv t))
      (error (e)
        (xlogft "lockme: error ~A ~%    lock ~s already in place, time ~a" e lockname (formatted-file-time fn))
		
        (setf rv nil)))
    rv))

(defun unlockme (lockname)
  (let ((fn (concatenate 'string lockname ",lck")))
    (xlogf "lockme: ulocking ~a" lockname)
    (if (probe-file fn)
		(sb-posix:unlink fn)
		(xlogntf "lockme: oops--file missing ~a" fn))
    t))


