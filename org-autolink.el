;;; org-autolink.el --- A company-mode backend to automatically create links to other org-mode files

;; Copyright (C) 2022  Damien Gonot
;; Keywords: org-mode, company-mode
;; Author: Damien Gonot <damien.gonot@gmail.com>

;;; Commentary:
;; A company-mode backend to automatically create links to other org-mode files

;;; Code:
(require 'cl)

(defun get-org-title (fPath)
  (with-temp-buffer
    (insert-file-contents fPath)
    (nth 1 (car (org-collect-keywords '("TITLE"))))))

(defun replace-title (title)
  (setq org-titles
    (mapcar
      (lambda (x) (cons (get-org-title x) x)) (directory-files-recursively org-directory "[a-z].org")))
  (delete-region (- (point) (length title)) (point))
  (insert (format "[[file:%s][%s]]" (file-relative-name (cdr (assoc title org-titles))) title)))

(defun org-links-backend (command &optional arg &rest ignored)
  (interactive (list 'interactive))

  (cl-case command
    (interactive (company-begin-backend 'org-links-backend))
    (prefix (and (or (eq major-mode 'org-mode) (eq major-mode 'org-journal-mode))
                (company-grab-symbol)))
    (candidates
      (remove-if-not
        (lambda (c) (string-prefix-p arg c t))
        (mapcar (lambda (x) (get-org-title x)) (directory-files-recursively org-directory "[a-z].org"))))
    (post-completion (replace-title arg))))

(provide 'org-autolink)
;;; org-autolink.el ends here
