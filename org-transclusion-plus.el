;;; org-transclusion-src-lines.el --- Extension -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(require 'org-element)
(declare-function text-clone-make-overlay 'text-clone)
;; (declare-function org-transclusion-live-sync-buffers-others-default
;;                   'org-transclusion)

;;;; Setting up the extension

;; Add a new transclusion type
(add-hook 'org-transclusion-add-functions
          #'org-transclusion-add-plus)
;; Keyword values
(add-hook 'org-transclusion-keyword-value-functions
          #'org-transclusion-keyword-value-plus)
(add-hook 'org-transclusion-keyword-plist-to-string-functions
          #'org-transclusion-keyword-plist-to-string-plus)

;; Transclusion content formating
;; Not needed. Default works for text files.


;;; Functions

(defun org-transclusion-add-plus (link plist)
  "Return a list for non-Org text and source file.
Determine add function based on LINK and PLIST.

Return nil if PLIST does not contain \":src\" or \":lines\" properties."
  (cond
   ((plist-get plist :plus)
    (append '(:tc-type "plus")
            (org-transclusion-content-plus link plist)))
   )
  )

(defun org-transclusion-content-plus (link plist)
  "Return a list of payload for a range of lines from LINK and PLIST.

You can specify a range of lines to transclude by adding the :line
property to a transclusion keyword like this:

    #+transclude: [[file:path/to/file.ext]] :lines 1-10

This is taken from Org Export (function
`org-export--inclusion-absolute-lines' in ox.el) with one
exception.  Instead of :lines 1-10 to exclude line 10, it has
been adjusted to include line 10.  This should be more intuitive
when it comes to including lines of code.

In order to transclude a single line, have the the same number in
both places (e.g. 10-10, meaning line 10 only).

One of the numbers can be omitted.  When the first number is
omitted (e.g. -10), it means from the beginning of the file to
line 10. Likewise, when the second number is omitted (e.g. 10-),
it means from line 10 to the end of file."
  (let* ((path (org-element-property :path link))
         (search-option (org-element-property :search-option link))
         (buf (find-file-noselect path))
         (plus (plist-get plist :plus)))
    (when buf
      (with-current-buffer buf
        (org-with-wide-buffer
         (let* (
                ;; (start-pos (or (when search-option
                ;;                  (save-excursion
                ;;                    (ignore-errors
                ;;                      (org-link-search search-option)
                ;;                      (line-beginning-position))))
                ;;                (point-min)))
                ;; (range (when lines (split-string lines "-")))
                ;; (lbeg (if range (string-to-number (car range))
                ;;         0))
                ;; (lend (if range (string-to-number (cadr range))
                ;;         0))
                ;;
                ;; (src (cadr (org-babel-lob--src-info plus)))
                (beg (point-min))
                (end (point-max))
                ;; (eval (car (read-from-string (format "(progn %s)" string))))
                ;; (content (buffer-substring-no-properties beg end))
                )

           (eval (car (read-from-string (format "(progn %s)" plus))))

           (list :src-content (buffer-substring-no-properties (point-min) (point-max))
                 :src-buf (current-buffer)
                 :src-beg beg
                 :src-end end)))))))


(defun org-transclusion-keyword-value-plus (string)
  "It is a utility function used converting a keyword STRING to plist.
It is meant to be used by `org-transclusion-get-string-to-plist'.
It needs to be set in
`org-transclusion-get-keyword-values-hook'.
Double qutations are mandatory."
  (when (string-match ":plus +\"\\(.*\\)\"" string)
    (list :plus (org-strip-quotes (match-string 1 string)))))

(defun org-transclusion-keyword-plist-to-string-plus (plist)
  "Convert a keyword PLIST to a string.
This function is meant to be used as an extension for function
`org-transclusion-keyword-plist-to-string'.  Add it to the
abnormal hook
`org-transclusion-keyword-plist-to-string-functions'."
  (let ((string nil)
        (plus (plist-get plist :plus))
        )
    (concat string
     (when plus (format ":plus %s" plus))
     )))


(provide 'org-transclusion-plus)
;;; org-transclusion-plus.el ends here

;; (add-to-list 'org-transclusion-extensions 'org-transclusion-plus)
