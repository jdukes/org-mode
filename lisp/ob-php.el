;;; ob-template.el --- org-babel functions for template evaluation

;; Copyright (C) your name here

;; Author: your name here
;; Keywords: literate programming, reproducible research
;; Homepage: http://orgmode.org
;; Version: 0.01

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; If you are planning on adding a language to org-babel we would ask
;; that if possible you fill out the FSF copyright assignment form
;; available at http://orgmode.org/request-assign-future.txt as this
;; will make it possible to include your language support in the core
;; of Org-mode, otherwise unassigned language support files can still
;; be included in the contrib/ directory of the Org-mode repository.

;;; Requirements:

;; php and php-mode

;; Use this section to list the requirements of this language.  Most
;; languages will require that at least the language be installed on
;; the user's system, and the Emacs major mode relevant to the
;; language be installed as well.

;;; Code:
(require 'ob)
(require 'ob-ref)
;;(require 'ob-comint)
(require 'ob-eval)
;;(require 'cl)

;; possibly require modes required for your language
;; (require 'php-mode)

;;(declare-function org-remove-indentation "org" )

;; optionally define a file extension for this language
(add-to-list 'org-babel-tangle-lang-exts '("php" . "php"))

(defvar org-babel-php-command "php"
"Name of command for executing PHP code.")

;; This function expands the body of a source code block by doing
;; things like prepending argument definitions to the body, it is
;; be called by the `org-babel-execute:php' function below.
(defun org-babel-expand-body:php (body params &optional processed-params)
  "Expand BODY according to PARAMS, return the expanded body."
  ;;(let ((vars (nth 1 (or processed-params (org-babel-process-params params)))))
  (let ((full-body
	 (org-babel-expand-body:generic
	  body
	  params
	  (org-babel-variable-assignments:php params))))
    (if (or (car (assoc :expand params)) nil)
	(concat "<?php\n"
		full-body
		"\n?>")
      full-body)))

(defun org-babel-execute:php (body params)
  (let* ((flags (or (cdr (assoc :flags params)) ""))
	 (src-file (make-temp-file nil nil ".php"))
	 (full-body (org-babel-expand-body:php body params))
	 (results
	  (progn
	    (with-temp-file src-file (insert full-body))
	    (org-babel-eval
	     (concat org-babel-php-command
		     " " flags " " src-file) ""))))
    (progn
      (org-babel-reassemble-table
       (org-babel-result-cond (cdr (assoc :result-params params))
	 (org-babel-read results)
         (let ((tmp-file (org-babel-temp-file "c-")))
           (with-temp-file tmp-file (insert results))
           (org-babel-import-elisp-from-file tmp-file)))
       (org-babel-pick-name
        (cdr (assoc :colname-names params)) (cdr (assoc :colnames params)))
       (org-babel-pick-name
        (cdr (assoc :rowname-names params)) (cdr (assoc :rownames params)))))))

(defun org-babel-variable-assignments:php (params)
  "Return a list of PHP statements assigning the block's variables."
  (mapcar
   (lambda (pair)
     ;;holy fuck I hate php
     (format "$%s=%s;"
	     (car pair)
	     (org-babel-php-var-to-php (cdr pair))))
   (mapcar #'cdr (org-babel-get-header params :var))))

(defun org-babel-php-var-to-php (var)
  "Convert an elisp var into a string of php source code
specifying a var of the same value."
  (if (listp var)
      (concat "Array(" (mapconcat #'org-babel-php-var-to-php var ",") ")")
  (format "%S" var)))

(defun org-babel-php-table-or-string (results)
  "If the results look like a table, then convert them into an
Emacs-lisp table, otherwise return the results as a string."
  (org-babel-script-escape results))

(provide 'ob-php)
;;; ob-php.el ends here
