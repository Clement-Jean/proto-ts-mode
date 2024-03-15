;;; proto-ts-mode-test.el --- Protobuf Mode: Unit test suite  -*- lexical-binding: t; -*-

;;; Code:
(require 'proto-ts-mode)
(require 'ert)

(defmacro proto-test-with-temp-buffer (content &rest body)
  "Evaluate BODY in a temporary buffer with CONTENT."
  (declare (debug t)
           (indent 1))
  `(with-temp-buffer
     (insert ,content)
     (proto-ts-mode)
     (font-lock-fontify-buffer)
     (goto-char (point-min))
     ,@body))

(defun proto-test-face-at (pos &optional content)
  "Get the face at POS in CONTENT.

If CONTENT is not given, return the face at POS in the current
buffer."
  (if content
      (proto-test-with-temp-buffer content
        (get-text-property pos 'face))
    (get-text-property pos 'face)))

(ert-deftest proto-ts-mode/fontify-syntax-proto3 ()
  :tags '(fontification syntax)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';"
   (should (eq (proto-test-face-at 1) 'font-lock-keyword-face)) ; 's'
   (should (eq (proto-test-face-at 8) nil)) ; '='
   (should (eq (proto-test-face-at 11) 'font-lock-string-face)) ; 'p'
   (should (eq (proto-test-face-at 18) nil)))) ; ';'

(ert-deftest proto-ts-mode/fontify-syntax-proto2 ()
  :tags '(fontification syntax)
  (proto-test-with-temp-buffer
   "syntax = 'proto2';"
   (should (eq (proto-test-face-at 1) 'font-lock-keyword-face)) ; 's'
   (should (eq (proto-test-face-at 8) nil)) ; '='
   (should (eq (proto-test-face-at 11) 'font-lock-string-face)) ; 'p'
   (should (eq (proto-test-face-at 18) nil)))) ; ';'

(ert-deftest proto-ts-mode/fontify-syntax-editions ()
  :tags '(fontification syntax)
  (proto-test-with-temp-buffer
   "syntax = 'editions';"
   (should (eq (proto-test-face-at 1) 'font-lock-keyword-face)) ; 's'
   (should (eq (proto-test-face-at 8) nil)) ; '='
   (should (eq (proto-test-face-at 11) 'font-lock-string-face)) ; 'p'
   (should (eq (proto-test-face-at 20) nil)))) ; ';'

(ert-deftest proto-ts-mode/fontify-edition ()
  :tags '(fontification edition)
  (proto-test-with-temp-buffer
   "edition = '2023';"
   (should (eq (proto-test-face-at 1) 'font-lock-keyword-face)) ; 'e'
   (should (eq (proto-test-face-at 9) nil)) ; '='
   (should (eq (proto-test-face-at 12) 'font-lock-string-face)) ; '2'
   (should (eq (proto-test-face-at 17) nil)))) ; ';'

(ert-deftest proto-ts-mode/fontify-package ()
  :tags '(fontification package)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
package test;"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'p'
   (should (eq (proto-test-face-at 28) 'font-lock-constant-face)) ; 't'
   (should (eq (proto-test-face-at 32) nil)))) ; ';'

(ert-deftest proto-ts-mode/fontify-package-full-ident ()
  :tags '(fontification package)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
package google.protobuf;"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'p'
   (should (eq (proto-test-face-at 28) 'font-lock-constant-face)) ; 'g'
   (should (eq (proto-test-face-at 34) nil)) ; '.'
   (should (eq (proto-test-face-at 35) 'font-lock-constant-face)) ; 'p'
   (should (eq (proto-test-face-at 43) nil)))) ; ';'

(ert-deftest proto-ts-mode/fontify-import ()
  :tags '(fontification import)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
import 'google/protobuf/empty.proto';"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'i'
   (should (eq (proto-test-face-at 28) 'font-lock-string-face)) ; 'g'
   (should (eq (proto-test-face-at 56) nil)))) ; ';'

(ert-deftest proto-ts-mode/fontify-import-weak ()
  :tags '(fontification import)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
import weak 'google/protobuf/empty.proto';"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'i'
   (should (eq (proto-test-face-at 27) 'font-lock-keyword-face)) ; 'w'
   (should (eq (proto-test-face-at 33) 'font-lock-string-face)) ; 'g'
   (should (eq (proto-test-face-at 61) nil)))) ; ';'

(ert-deftest proto-ts-mode/fontify-import-public ()
  :tags '(fontification import)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
import public 'google/protobuf/empty.proto';"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'i'
   (should (eq (proto-test-face-at 27) 'font-lock-keyword-face)) ; 'p'
   (should (eq (proto-test-face-at 35) 'font-lock-string-face)) ; 'g'
   (should (eq (proto-test-face-at 63) nil)))) ; ';'

(ert-deftest proto-ts-mode/fontify-option-bool ()
  :tags '(fontification option)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
option deprecated = true;"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'o'
   (should (eq (proto-test-face-at 27) 'font-lock-constant-face)) ; 'd'
   (should (eq (proto-test-face-at 38) nil)) ; '='
   (should (eq (proto-test-face-at 40) 'font-lock-constant-face)) ; 't'
   (should (eq (proto-test-face-at 44) nil)))) ; ';'

(ert-deftest proto-ts-mode/fontify-option-positive-int ()
  :tags '(fontification option)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
option deprecated = 1;"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'o'
   (should (eq (proto-test-face-at 27) 'font-lock-constant-face)) ; 'd'
   (should (eq (proto-test-face-at 38) nil)) ; '='
   (should (eq (proto-test-face-at 40) 'font-lock-constant-face)) ; '1'
   (should (eq (proto-test-face-at 41) nil)))) ; ';'

(ert-deftest proto-ts-mode/fontify-option-negative-int ()
  :tags '(fontification option)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
option deprecated = -1;"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'o'
   (should (eq (proto-test-face-at 27) 'font-lock-constant-face)) ; 'd'
   (should (eq (proto-test-face-at 38) nil)) ; '='
   (should (eq (proto-test-face-at 40) 'font-lock-constant-face)) ; '-'
   (should (eq (proto-test-face-at 41) 'font-lock-constant-face)) ; '1'
   (should (eq (proto-test-face-at 42) nil)))) ; ';'

(ert-deftest proto-ts-mode/fontify-option-octal ()
  :tags '(fontification option)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
option deprecated = 07;"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'o'
   (should (eq (proto-test-face-at 27) 'font-lock-constant-face)) ; 'd'
   (should (eq (proto-test-face-at 38) nil)) ; '='
   (should (eq (proto-test-face-at 40) 'font-lock-constant-face)) ; '0'
   (should (eq (proto-test-face-at 41) 'font-lock-constant-face)) ; '7'
   (should (eq (proto-test-face-at 42) nil)))) ; ';'

(ert-deftest proto-ts-mode/fontify-option-hexadecimal ()
  :tags '(fontification option)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
option deprecated = 0x7;"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'o'
   (should (eq (proto-test-face-at 27) 'font-lock-constant-face)) ; 'd'
   (should (eq (proto-test-face-at 38) nil)) ; '='
   (should (eq (proto-test-face-at 40) 'font-lock-constant-face)) ; '0'
   (should (eq (proto-test-face-at 43) nil)))) ; ';'

(ert-deftest proto-ts-mode/fontify-option-positive-float ()
  :tags '(fontification option)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
option deprecated = 0.7;"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'o'
   (should (eq (proto-test-face-at 27) 'font-lock-constant-face)) ; 'd'
   (should (eq (proto-test-face-at 38) nil)) ; '='
   (should (eq (proto-test-face-at 40) 'font-lock-constant-face)) ; '0'
   (should (eq (proto-test-face-at 41) 'font-lock-constant-face)) ; '.'
   (should (eq (proto-test-face-at 42) 'font-lock-constant-face)) ; '7'
   (should (eq (proto-test-face-at 43) nil)))) ; ';'

(ert-deftest proto-ts-mode/fontify-option-negative-float ()
  :tags '(fontification option)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
option deprecated = -0.7;"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'o'
   (should (eq (proto-test-face-at 27) 'font-lock-constant-face)) ; 'd'
   (should (eq (proto-test-face-at 38) nil)) ; '='
   (should (eq (proto-test-face-at 40) 'font-lock-constant-face)) ; '-'
   (should (eq (proto-test-face-at 41) 'font-lock-constant-face)) ; '0'
   (should (eq (proto-test-face-at 42) 'font-lock-constant-face)) ; '.'
   (should (eq (proto-test-face-at 43) 'font-lock-constant-face)) ; '7'
   (should (eq (proto-test-face-at 44) nil)))) ; ';'

(ert-deftest proto-ts-mode/fontify-option-string ()
  :tags '(fontification option)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
option deprecated = 'true';"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'o'
   (should (eq (proto-test-face-at 27) 'font-lock-constant-face)) ; 'd'
   (should (eq (proto-test-face-at 38) nil)) ; '='
   (should (eq (proto-test-face-at 41) 'font-lock-string-face)) ; 't'
   (should (eq (proto-test-face-at 46) nil)))) ; ';'

(ert-deftest proto-ts-mode/fontify-option-custom ()
  :tags '(fontification option)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
option (custom).id = true;"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'o'
   (should (eq (proto-test-face-at 27) nil)) ; '('
   (should (eq (proto-test-face-at 28) 'font-lock-constant-face)) ; 'c'
   (should (eq (proto-test-face-at 34) nil)) ; ')'
   (should (eq (proto-test-face-at 35) nil)) ; '.'
   (should (eq (proto-test-face-at 36) 'font-lock-constant-face)) ; 'i'
   (should (eq (proto-test-face-at 39) nil)) ; '='
   (should (eq (proto-test-face-at 41) 'font-lock-constant-face)) ; 't'
   (should (eq (proto-test-face-at 45) nil)))) ; ';'

(ert-deftest proto-ts-mode/fontify-option-custom-full-ident-name ()
  :tags '(fontification option)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
option (custom.test).id = true;"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'o'
   (should (eq (proto-test-face-at 27) nil)) ; '('
   (should (eq (proto-test-face-at 28) 'font-lock-constant-face)) ; 'c'
   (should (eq (proto-test-face-at 34) nil)) ; '.'
   (should (eq (proto-test-face-at 35) 'font-lock-constant-face)) ; 't'
   (should (eq (proto-test-face-at 39) nil)) ; ')'
   (should (eq (proto-test-face-at 40) nil)) ; '.'
   (should (eq (proto-test-face-at 41) 'font-lock-constant-face)) ; 'i'
   (should (eq (proto-test-face-at 44) nil)) ; '='
   (should (eq (proto-test-face-at 46) 'font-lock-constant-face)) ; 't'
   (should (eq (proto-test-face-at 50) nil)))) ; ';'

(ert-deftest proto-ts-mode/fontify-message ()
  :tags '(fontification message)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
message Test {}"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'm'
   (should (eq (proto-test-face-at 28) 'font-lock-type-face)) ; 'T'
   (should (eq (proto-test-face-at 33) nil)) ; '{'
   (should (eq (proto-test-face-at 34) nil)))) ; '}'

(ert-deftest proto-ts-mode/fontify-message-empty-statement ()
  :tags '(fontification message)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
message Test {;}"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'm'
   (should (eq (proto-test-face-at 28) 'font-lock-type-face)) ; 'T'
   (should (eq (proto-test-face-at 33) nil)) ; '{'
   (should (eq (proto-test-face-at 34) nil)) ; ';'
   (should (eq (proto-test-face-at 34) nil)))) ; '}'

(ert-deftest proto-ts-mode/fontify-message-option ()
  :tags '(fontification message)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
message Test { option deprecated = true; }"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'm'
   (should (eq (proto-test-face-at 28) 'font-lock-type-face)) ; 'T'
   (should (eq (proto-test-face-at 33) nil)) ; '{'
   (should (eq (proto-test-face-at 35) 'font-lock-keyword-face)) ; 'o'
   (should (eq (proto-test-face-at 42) 'font-lock-constant-face)) ; 'd'
   (should (eq (proto-test-face-at 53) nil)) ; '='
   (should (eq (proto-test-face-at 55) 'font-lock-constant-face)) ; 't'
   (should (eq (proto-test-face-at 59) nil)) ; ';'
   (should (eq (proto-test-face-at 61) nil)))) ; '}'

(ert-deftest proto-ts-mode/fontify-message-field ()
  :tags '(fontification message)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
message Test { uint64 id = 1; }"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'm'
   (should (eq (proto-test-face-at 28) 'font-lock-type-face)) ; 'T'
   (should (eq (proto-test-face-at 33) nil)) ; '{'
   (should (eq (proto-test-face-at 35) 'font-lock-type-face)) ; 'u'
   (should (eq (proto-test-face-at 42) 'font-lock-variable-name-face)) ; 'i'
   (should (eq (proto-test-face-at 45) nil)) ; '='
   (should (eq (proto-test-face-at 47) 'font-lock-constant-face)) ; '1'
   (should (eq (proto-test-face-at 48) nil)) ; ';'
   (should (eq (proto-test-face-at 50) nil)))) ; '}'

(ert-deftest proto-ts-mode/fontify-message-repeated-field ()
  :tags '(fontification message)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
message Test { repeated uint64 id = 1; }"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'm'
   (should (eq (proto-test-face-at 28) 'font-lock-type-face)) ; 'T'
   (should (eq (proto-test-face-at 33) nil)) ; '{'
   (should (eq (proto-test-face-at 35) 'font-lock-keyword-face)) ; 'r'
   (should (eq (proto-test-face-at 44) 'font-lock-type-face)) ; 'u'
   (should (eq (proto-test-face-at 51) 'font-lock-variable-name-face)) ; 'i'
   (should (eq (proto-test-face-at 54) nil)) ; '='
   (should (eq (proto-test-face-at 56) 'font-lock-constant-face)) ; '1'
   (should (eq (proto-test-face-at 57) nil)) ; ';'
   (should (eq (proto-test-face-at 59) nil)))) ; '}'

(ert-deftest proto-ts-mode/fontify-message-optional-field ()
  :tags '(fontification message)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
message Test { optional uint64 id = 1; }"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'm'
   (should (eq (proto-test-face-at 28) 'font-lock-type-face)) ; 'T'
   (should (eq (proto-test-face-at 33) nil)) ; '{'
   (should (eq (proto-test-face-at 35) 'font-lock-keyword-face)) ; 'r'
   (should (eq (proto-test-face-at 44) 'font-lock-type-face)) ; 'u'
   (should (eq (proto-test-face-at 51) 'font-lock-variable-name-face)) ; 'i'
   (should (eq (proto-test-face-at 54) nil)) ; '='
   (should (eq (proto-test-face-at 56) 'font-lock-constant-face)) ; '1'
   (should (eq (proto-test-face-at 57) nil)) ; ';'
   (should (eq (proto-test-face-at 59) nil)))) ; '}'

(ert-deftest proto-ts-mode/fontify-message-required-field ()
  :tags '(fontification message)
  (proto-test-with-temp-buffer
   "syntax = 'proto2';
message Test { required uint64 id = 1; }"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'm'
   (should (eq (proto-test-face-at 28) 'font-lock-type-face)) ; 'T'
   (should (eq (proto-test-face-at 33) nil)) ; '{'
   (should (eq (proto-test-face-at 35) 'font-lock-keyword-face)) ; 'r'
   (should (eq (proto-test-face-at 44) 'font-lock-type-face)) ; 'u'
   (should (eq (proto-test-face-at 51) 'font-lock-variable-name-face)) ; 'i'
   (should (eq (proto-test-face-at 54) nil)) ; '='
   (should (eq (proto-test-face-at 56) 'font-lock-constant-face)) ; '1'
   (should (eq (proto-test-face-at 57) nil)) ; ';'
   (should (eq (proto-test-face-at 59) nil)))) ; '}'

(ert-deftest proto-ts-mode/fontify-enum ()
  :tags '(fontification enum)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
enum Test {}"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'e'
   (should (eq (proto-test-face-at 25) 'font-lock-type-face)) ; 'T'
   (should (eq (proto-test-face-at 30) nil)) ; '{'
   (should (eq (proto-test-face-at 31) nil)))) ; '}'

(ert-deftest proto-ts-mode/fontify-enum-empty-statement ()
  :tags '(fontification enum)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
enum Test {;}"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'e'
   (should (eq (proto-test-face-at 25) 'font-lock-type-face)) ; 'T'
   (should (eq (proto-test-face-at 30) nil)) ; '{'
   (should (eq (proto-test-face-at 31) nil)) ; ';'
   (should (eq (proto-test-face-at 32) nil)))) ; '}'

(ert-deftest proto-ts-mode/fontify-enum-option ()
  :tags '(fontification enum)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
enum Test { option deprecated = true; }"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'm'
   (should (eq (proto-test-face-at 25) 'font-lock-type-face)) ; 'T'
   (should (eq (proto-test-face-at 30) nil)) ; '{'
   (should (eq (proto-test-face-at 32) 'font-lock-keyword-face)) ; 'o'
   (should (eq (proto-test-face-at 39) 'font-lock-constant-face)) ; 'd'
   (should (eq (proto-test-face-at 50) nil)) ; '='
   (should (eq (proto-test-face-at 52) 'font-lock-constant-face)) ; 't'
   (should (eq (proto-test-face-at 56) nil)) ; ';'
   (should (eq (proto-test-face-at 58) nil)))) ; '}'

(ert-deftest proto-ts-mode/fontify-enum-value ()
  :tags '(fontification enum)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
enum Test { TEST_UNSPECIFIED = 0; }"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'e'
   (should (eq (proto-test-face-at 25) 'font-lock-type-face)) ; 'T'
   (should (eq (proto-test-face-at 30) nil)) ; '{'
   (should (eq (proto-test-face-at 32) 'font-lock-variable-name-face)) ; 'T'
   (should (eq (proto-test-face-at 49) nil)) ; '='
   (should (eq (proto-test-face-at 51) 'font-lock-constant-face)) ; '0'
   (should (eq (proto-test-face-at 52) nil)) ; ';'
   (should (eq (proto-test-face-at 54) nil)))) ; '}'

(ert-deftest proto-ts-mode/fontify-service ()
  :tags '(fontification service)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
service Test {}"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'e'
   (should (eq (proto-test-face-at 28) 'font-lock-type-face)) ; 'T'
   (should (eq (proto-test-face-at 33) nil)) ; '{'
   (should (eq (proto-test-face-at 34) nil)))) ; '}'

(ert-deftest proto-ts-mode/fontify-service-empty-statement ()
  :tags '(fontification service)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
service Test {;}"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'e'
   (should (eq (proto-test-face-at 28) 'font-lock-type-face)) ; 'T'
   (should (eq (proto-test-face-at 33) nil)) ; '{'
   (should (eq (proto-test-face-at 34) nil)) ; ';'
   (should (eq (proto-test-face-at 35) nil)))) ; '}'

(ert-deftest proto-ts-mode/fontify-service-option ()
  :tags '(fontification service)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
service Test { option deprecated = true; }"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'm'
   (should (eq (proto-test-face-at 28) 'font-lock-type-face)) ; 'T'
   (should (eq (proto-test-face-at 33) nil)) ; '{'
   (should (eq (proto-test-face-at 35) 'font-lock-keyword-face)) ; 'o'
   (should (eq (proto-test-face-at 42) 'font-lock-constant-face)) ; 'd'
   (should (eq (proto-test-face-at 53) nil)) ; '='
   (should (eq (proto-test-face-at 55) 'font-lock-constant-face)) ; 't'
   (should (eq (proto-test-face-at 59) nil)) ; ';'
   (should (eq (proto-test-face-at 61) nil)))) ; '}'

(ert-deftest proto-ts-mode/fontify-service-rpc ()
  :tags '(fontification service)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
service Test { rpc Method(Empty) returns (Empty); }"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'e'
   (should (eq (proto-test-face-at 28) 'font-lock-type-face)) ; 'T'
   (should (eq (proto-test-face-at 33) nil)) ; '{'
   (should (eq (proto-test-face-at 35) 'font-lock-keyword-face)) ; 'r'
   (should (eq (proto-test-face-at 39) 'font-lock-function-name-face)) ; 'M'
   (should (eq (proto-test-face-at 45) nil)) ; '('
   (should (eq (proto-test-face-at 46) 'font-lock-type-face)) ; 'E'
   (should (eq (proto-test-face-at 51) nil)) ; ')'
   (should (eq (proto-test-face-at 53) 'font-lock-keyword-face)) ; 'r'
   (should (eq (proto-test-face-at 61) nil)) ; '('
   (should (eq (proto-test-face-at 62) 'font-lock-type-face)) ; 'E'
   (should (eq (proto-test-face-at 67) nil)) ; ')'
   (should (eq (proto-test-face-at 68) nil)) ; ';'
   (should (eq (proto-test-face-at 70) nil)))) ; '}'

(ert-deftest proto-ts-mode/fontify-service-rpc-stream ()
  :tags '(fontification service)
  (proto-test-with-temp-buffer
   "syntax = 'proto3';
service Test { rpc Method(stream Empty) returns (stream Empty); }"
   (should (eq (proto-test-face-at 20) 'font-lock-keyword-face)) ; 'e'
   (should (eq (proto-test-face-at 28) 'font-lock-type-face)) ; 'T'
   (should (eq (proto-test-face-at 33) nil)) ; '{'
   (should (eq (proto-test-face-at 35) 'font-lock-keyword-face)) ; 'r'
   (should (eq (proto-test-face-at 39) 'font-lock-function-name-face)) ; 'M'
   (should (eq (proto-test-face-at 45) nil)) ; '('
   (should (eq (proto-test-face-at 46) 'font-lock-keyword-face)) ; 's'
   (should (eq (proto-test-face-at 53) 'font-lock-type-face)) ; 'E'
   (should (eq (proto-test-face-at 58) nil)) ; ')'
   (should (eq (proto-test-face-at 60) 'font-lock-keyword-face)) ; 'r'
   (should (eq (proto-test-face-at 68) nil)) ; '('
   (should (eq (proto-test-face-at 69) 'font-lock-keyword-face)) ; 's'
   (should (eq (proto-test-face-at 76) 'font-lock-type-face)) ; 'E'
   (should (eq (proto-test-face-at 81) nil)) ; ')'
   (should (eq (proto-test-face-at 82) nil)) ; ';'
   (should (eq (proto-test-face-at 84) nil)))) ; '}'

(provide 'proto-ts-mode-test)

;;; proto-ts-mode-test.el ends here
