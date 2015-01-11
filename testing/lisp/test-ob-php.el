;;; test-ob-php.el --- tests for ob-php.el

;; Copyright (c) 2014 Josh Dukes
;; Authors: Josh Dukes

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Code:
(unless (featurep 'ob-php)
  (signal 'missing-test-dependency "Support for PHP code blocks"))

(ert-deftest ob-php/assert ()
  (should t))

;;expand tests

(ert-deftest ob-php/hello-world ()
  "Hello world program."
  (org-test-at-id "39b75bdf-0f2a-4e7a-a03c-4c2bfa96bf60"
    (org-babel-next-src-block) 
    (should (equal "hello world" (org-babel-execute-src-block)))))

(ert-deftest ob-php/intreturn ()
  "return an int."
  (org-test-at-id "39b75bdf-0f2a-4e7a-a03c-4c2bfa96bf60"
    (org-babel-next-src-block 2) 
    (should (= 42 (org-babel-execute-src-block)))))

(ert-deftest ob-php/expandvar ()
  "expand with variables."
  (org-test-at-id "39b75bdf-0f2a-4e7a-a03c-4c2bfa96bf60"
    (org-babel-next-src-block 3) 
    (should (equal "1 bar" (org-babel-execute-src-block)))))

(ert-deftest ob-php/multiline ()
  "expand with variables."
  (org-test-at-id "39b75bdf-0f2a-4e7a-a03c-4c2bfa96bf60"
    (org-babel-next-src-block 4) 
    (should (equal '(("php!")("sucks!")) (org-babel-execute-src-block)))))

;; noexpand tests

(ert-deftest ob-php/external-block ()
  "outside php block, inside php block."
  (org-test-at-id "47f2043a-abc9-4059-92bf-5df939e6881b"
    (org-babel-next-src-block) 
    (should (equal '(("outside" "php")("inside" "php")) (org-babel-execute-src-block)))))

;;array tests

(ert-deftest ob-php/fromvar ()
  "get value from variable in an unexpanded block."
  (org-test-at-id "2472b4b4-6582-44ca-844d-6a8299dd728b"
    (org-babel-next-src-block)
    (should (equal '(("value:" "baz")("value:" "bar")) (org-babel-execute-src-block)))))

(ert-deftest ob-php/fromvarexpand ()
  "get value from variable in an unexpanded block."
  (org-test-at-id "2472b4b4-6582-44ca-844d-6a8299dd728b"
    (org-babel-next-src-block 2)
    (should (equal '(("value:" "baz")("value:" "bar")) (org-babel-execute-src-block)))))
