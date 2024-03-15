;;; proto-ts-mode.el --- Major mode for Proto files  -*- lexical-binding: t; -*-

;; Copyright (C) 2024, 2025  Clement Jean <clement.jean@epitech.eu>

;; Author: Clement Jean <clement.jean@epitech.eu>
;; Maintainer: Clement Jean <clement.jean@epitech.eu>
;; URL: https://github.com/Clement-Jean/proto-ts-mode
;; Keywords: languages, protobuf
;; Version: 0.1
;; Package-Requires: ((emacs "29.2") (pkg-info "0.1"))

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;; This file incorporates work covered by the following copyright and
;; permission notice:

;;   Licensed under the Apache License, Version 2.0 (the "License"); you may not
;;   use this file except in compliance with the License.  You may obtain a copy
;;   of the License at
;;
;;       http://www.apache.org/licenses/LICENSE-2.0
;;
;;   Unless required by applicable law or agreed to in writing, software
;;   distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
;;   WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
;;   License for the specific language governing permissions and limitations
;;   under the License.

;;; Commentary:

;;; Code:

(require 'treesit)

(defvar proto-ts-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?/  ". 124b" st)
    (modify-syntax-entry ?*  ". 23" st)
    (modify-syntax-entry ?\n "> b" st)
    (modify-syntax-entry ?\( "()" st)
    (modify-syntax-entry ?\) ")(" st)
    (modify-syntax-entry ?\{ "(}" st)
    (modify-syntax-entry ?\} "){" st)
    (modify-syntax-entry ?\[ "(]" st)
    (modify-syntax-entry ?\] ")[" st)
    (modify-syntax-entry ?\< "(>" st)
    (modify-syntax-entry ?\> ")<" st)
    (modify-syntax-entry ?\" "\"" st)
    (modify-syntax-entry ?\' "'" st)
    (modify-syntax-entry ?\. "." st)
    (modify-syntax-entry ?\, "." st)
    st))

(defvar proto-ts-font-lock-rules
  '(:feature comment
    :language proto
    ((comment) @font-lock-comment-face)

    :feature string
    :language proto
    ((string) @font-lock-string-face)

    :feature syntax
    :language proto
    ((syntax2
      keyword: _ @font-lock-keyword-face
      version: _ @font-lock-string-face)
     (syntax3
      keyword: _ @font-lock-keyword-face
      version: _ @font-lock-string-face)
     (syntaxEditions
      keyword: _ @font-lock-keyword-face
      version: _ @font-lock-string-face))

    :feature edition
    :language proto
    ((edition
      keyword: _ @font-lock-keyword-face
      version: _ @font-lock-string-face))

    :feature package
    :language proto
    ((package
      keyword: _ @font-lock-keyword-face
      (full_ident
       part: _ @font-lock-constant-face)))

    :feature import
    :language proto
    ((import
      keyword: _ @font-lock-keyword-face
      modifier: _? @font-lock-keyword-face
      path: (string)))

    :feature option
    :language proto
    ((option
      keyword: _ @font-lock-keyword-face
      name: (option_name
	     (full_ident
	      part: _ @font-lock-constant-face)
	     (identifier)* @font-lock-constant-face))
     (option
      keyword: _ @font-lock-keyword-face
      name: _ @font-lock-constant-face
      value: (constant))
     (value_option
      name: (option_name
	     (full_ident
	      part: _ @font-lock-constant-face)
	     (identifier)* @font-lock-constant-face))
     (value_option
      name: _ @font-lock-constant-face
      value: (constant) @font-lock-constant-face)
     (field_option
      name: (option_name
	     (full_ident
	      part: _ @font-lock-constant-face)
	     (identifier)* @font-lock-constant-face))
     (field_option
      name: _ @font-lock-constant-face
      value: (constant) @font-lock-constant-face))

    :feature message
    :language proto
    ((message
      keyword: _ @font-lock-keyword-face
      name: (message_name) @font-lock-type-face))

    :feature reserved
    :language proto
    ((reserved
      keyword: _ @font-lock-keyword-face)
     (reserved
      keyword: _ @font-lock-keyword-face
      (ranges
       (range
	start: _ @font-lock-constant-face
	keyword: _? @font-lock-keyword-face
	end: _? @font-lock-constant-face))))

    :feature extensions
    :language proto
    ((extensions
      keyword: _ @font-lock-keyword-face
      (ranges
       (range
	start: _ @font-lock-constant-face
	keyword: _? @font-lock-keyword-face
	end: _? @font-lock-constant-face))))

    :feature field
    :language proto
    ((field
      label: _ @font-lock-keyword-face
      type: (type
	     (message_or_enum_type
	      part: _? @font-lock-constant-face
	      type: _ @font-lock-type-face))
      name: _ @font-lock-variable-name-face
      tag: _ @font-lock-constant-face)
     (field
      type: (type
	     (message_or_enum_type
	      part: _? @font-lock-constant-face
	      type: _ @font-lock-type-face))
      name: _ @font-lock-variable-name-face
      tag: _ @font-lock-constant-face)
     (field
      label: _ @font-lock-keyword-face
      type: _ @font-lock-type-face
      name: _ @font-lock-variable-name-face
      tag: _ @font-lock-constant-face)
     (field
      type: _ @font-lock-type-face
      name: _ @font-lock-variable-name-face
      tag: _ @font-lock-constant-face)
     (group_field
      label: _ @font-lock-keyword-face
      keyword: _ @font-lock-keyword-face
      name: _ @font-lock-type-face
      tag: _ @font-lock-constant-face
      (message_body _))
     (map_field
      keyword: _ @font-lock-keyword-face
      key_type: _ @font-lock-type-face
      val_type: _ @font-lock-type-face
      name: _ @font-lock-type-face
      tag: _ @font-lock-constant-face))

    :feature oneof
    :language proto
    ((oneof
      keyword: _ @font-lock-keyword-face
      name: _ @font-lock-type-face
      (oneof_body)))

    :feature enum
    :language proto
    ((enum
      keyword: _ @font-lock-keyword-face
      name: (enum_name) @font-lock-type-face))

    :feature value
    :language proto
    ((value
      name: _ @font-lock-variable-name-face
      tag: _ @font-lock-constant-face))

    :feature service
    :language proto
    ((service
      keyword: _ @font-lock-keyword-face
      name: (service_name) @font-lock-type-face))

    :feature rpc
    :language proto
    ((rpc
      keyword: _ @font-lock-keyword-face
      name: (rpc_name) @font-lock-function-name-face
      is_stream: _? @font-lock-keyword-face
      arg_type: (message_or_enum_type
		 part: _? @font-lock-constant-face
		 type: _ @font-lock-type-face)
      keyword: _ @font-lock-keyword-face
      is_stream: _? @font-lock-keyword-face
      ret_type: (message_or_enum_type
		 part: _? @font-lock-constant-face
		 type: _ @font-lock-type-face)))

    :feature extend
    :language proto
    ((extend
      keyword: _ @font-lock-keyword-face
      name: (message_or_enum_type
	     part: _? @font-lock-constant-face
	     type: _ @font-lock-type-face)))

    :feature constant
    :language proto
    ((constant (bool)) @font-lock-constant-face
     (constant (string)) @font-lock-string-face
     (constant (int_lit)) @font-lock-constant-face
     (constant (float_lit)) @font-lock-constant-face
     (constant (full_ident
		part: _ @font-lock-constant-face))
     (message_value
      name: _ @font-lock-variable-name-face)
     (message_value
      name: _ @font-lock-variable-name-face)
     (message_value
      name: _ @font-lock-variable-name-face)
     (message_value
      name: _ @font-lock-variable-name-face)
     (message_value
      name: _ @font-lock-variable-name-face
      value: (constant (message_value))))
))

(defvar proto-ts-indent-rules
  (let ((offset 2))
    `((proto
       ((parent-is "source_file") parent-bol 0)
       ((node-is "}") parent-bol 0)
       ((node-is ")") parent-bol 0)
       ((node-is "]") parent-bol 0)
       ((node-is ">") parent-bol 0)
       ((parent-is "message") parent-bol, offset)
       ((parent-is "enum") parent-bol, offset)
       ((parent-is "service") parent-bol, offset)
       ((parent-is "oneof") parent-bol, offset)
       ((parent-is "extend") parent-bol, offset)
       ((parent-is "group") parent-bol, offset)
       ((parent-is "block_lit") parent-bol, offset)
       ((parent-is "field_options") parent-bol, offset)
       ((parent-is "value_options") parent-bol, offset)
       ((parent-is "rpc_body") parent-bol, offset)))))

(defun proto-ts-msg-imenu-node-p (node)
  (equal (treesit-node-type node) "message_name"))

(defun proto-ts-enu-imenu-node-p (node)
  (equal (treesit-node-type node) "enum_name"))

(defun proto-ts-svc-imenu-node-p (node)
  (equal (treesit-node-type node) "service_name"))

(defun proto-ts-imenu-name-function (node)
  (let ((name (treesit-node-text node))) name))

;;;###autoload
(define-derived-mode proto-ts-mode prog-mode "Protocol Buffers"
  :syntax-table proto-ts-syntax-table
  (when (treesit-ready-p 'proto)
    (treesit-parser-create 'proto)
    (setq-local comment-start "// "
		comment-start-skip "//+?\\s-*")
    (setq-local treesit-font-lock-settings
		(apply #'treesit-font-lock-rules
                       proto-ts-font-lock-rules))
    (setq-local treesit-font-lock-feature-list
                '((comment
		   string
		   syntax
		   edition
		   package
		   import
		   option
		   message
		   reserved
		   extensions
		   field
		   oneof
		   enum
		   value
		   service
		   rpc
		   extend
		   constant)))
    (setq-local treesit-simple-indent-rules proto-ts-indent-rules)
    (setq-local treesit-simple-imenu-settings
		`(("Messages"
		   proto-ts-msg-imenu-node-p nil proto-ts-imenu-name-function)
		  ("Enums"
		   proto-ts-enu-imenu-node-p nil proto-ts-imenu-name-function)
		  ("Services"
		   proto-ts-svc-imenu-node-p nil proto-ts-imenu-name-function)))
    (treesit-major-mode-setup)))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.proto\\'" . proto-ts-mode))

(provide 'proto-ts-mode)

;;; proto-ts-mode.el ends here
