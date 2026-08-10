;;; +todo.el -*- lexical-binding: t; -*-

;; Browse hl-todo keywords (TODO, FIXME, NOTE, HACK, ...) with consult.
;; Matching is done up front, so the input box is empty — you just type
;; to filter the result list. Results are grouped by keyword.

(require 'cl-lib)

(defvar +todo-extra-keywords nil
  "Extra keywords to treat as TODOs, on top of `hl-todo-keyword-faces'.")

(defvar +todo--lookup nil
  "Hash table mapping stripped candidate strings to entry plists.
Bound by `+todo--browse' across collection and selection, because
consult strips text properties from candidates before passing them
to the state function.")

(defun +todo--keywords ()
  (require 'hl-todo)
  (delete-dups (append (mapcar #'car hl-todo-keyword-faces)
                       +todo-extra-keywords)))

(defun +todo--rg-regex ()
  (concat "\\b(" (mapconcat #'regexp-quote (+todo--keywords) "|") ")\\b"))

(defun +todo--elisp-regex ()
  (concat "\\_<\\(" (mapconcat #'regexp-quote (+todo--keywords) "\\|") "\\)\\_>"))

(defun +todo--keyword-face (kw)
  (require 'hl-todo)
  (or (cdr (assoc kw hl-todo-keyword-faces)) 'hl-todo))

(defun +todo--keyword-rank (kw)
  (or (cl-position kw (mapcar #'car hl-todo-keyword-faces) :test #'equal)
      most-positive-fixnum))

(defun +todo--keyword-of (text)
  (when (string-match (+todo--elisp-regex) text)
    (match-string-no-properties 1 text)))

(defun +todo--format (file line text root)
  "Build a candidate string for one TODO match and register it in `+todo--lookup'."
  (let* ((kw    (+todo--keyword-of text))
         (rel   (if (and root (file-name-absolute-p file))
                    (file-relative-name file root)
                  file))
         (head  (format "%s:%d" rel line))
         (text  (string-trim text))
         (cand  (format "%-32s  %s" head text)))
    (add-face-text-property 0 (min (length head) (length cand))
                            'completions-annotations nil cand)
    (when kw
      (when-let ((start (string-match (regexp-quote kw) cand (length head))))
        (add-face-text-property start (+ start (length kw))
                                (+todo--keyword-face kw) nil cand)))
    (puthash (substring-no-properties cand)
             (list :file file :line line :keyword kw)
             +todo--lookup)
    cand))

(defun +todo--rg-collect (dir)
  "Run ripgrep in DIR; return list of formatted candidate strings."
  (let* ((default-directory (file-name-as-directory (expand-file-name dir)))
         (rg (executable-find "rg")))
    (unless rg (user-error "ripgrep (`rg') not found on PATH"))
    (with-temp-buffer
      (let ((status (call-process rg nil t nil
                                  "--no-heading" "--line-number"
                                  "--color=never" "--no-messages"
                                  (+todo--rg-regex))))
        ;; rg exits 0 on hits, 1 on no hits; anything else is a real error.
        (when (memq status '(0 1))
          (let (results)
            (goto-char (point-min))
            (while (not (eobp))
              (let ((line (buffer-substring-no-properties
                           (line-beginning-position) (line-end-position))))
                (when (string-match "\\`\\([^\0]+?\\):\\([0-9]+\\):\\(.*\\)\\'" line)
                  (push (+todo--format
                         (expand-file-name (match-string 1 line) default-directory)
                         (string-to-number (match-string 2 line))
                         (match-string 3 line)
                         default-directory)
                        results)))
              (forward-line 1))
            (nreverse results)))))))

(defun +todo--buffer-collect (&optional buffer)
  (let ((regex (+todo--elisp-regex))
        (buf (or buffer (current-buffer)))
        results)
    (with-current-buffer buf
      (save-excursion
        (goto-char (point-min))
        (while (re-search-forward regex nil t)
          (let ((line (line-number-at-pos))
                (text (buffer-substring-no-properties
                       (line-beginning-position)
                       (line-end-position))))
            (push (+todo--format
                   (or (buffer-file-name) (buffer-name))
                   line text nil)
                  results)))))
    (nreverse results)))

(defun +todo--entry (cand)
  "Look up the entry plist for candidate string CAND."
  (and cand +todo--lookup
       (gethash (substring-no-properties cand) +todo--lookup)))

(defun +todo--group (cand transform)
  (if transform cand
    (or (plist-get (+todo--entry cand) :keyword) "OTHER")))

(defun +todo--by-keyword (cands)
  (sort (copy-sequence cands)
        (lambda (a b)
          (< (+todo--keyword-rank (plist-get (+todo--entry a) :keyword))
             (+todo--keyword-rank (plist-get (+todo--entry b) :keyword))))))

(defun +todo--resolve-buffer (file)
  "Return (BUFFER . NEW?) for FILE. NEW? is t if we just opened the file."
  (cond
   ((and file (file-exists-p file))
    (if-let ((existing (find-buffer-visiting file)))
        (cons existing nil)
      (cons (find-file-noselect file t) t)))
   ((and file (get-buffer file))
    (cons (get-buffer file) nil))))

(defun +todo--goto-line (buf line)
  "Show BUF in the current window and move point to LINE."
  (switch-to-buffer buf t t)
  (goto-char (point-min))
  (forward-line (1- line))
  (recenter))

(defun +todo--make-line-overlay ()
  "Highlight the current line in the current buffer for preview."
  (let ((ov (make-overlay (line-beginning-position)
                          (min (point-max) (1+ (line-end-position))))))
    (overlay-put ov 'category 'consult-preview-line-overlay)
    (overlay-put ov 'window (selected-window))
    ov))

(defun +todo--state ()
  "State function: live preview with line highlight; cleanup on exit.
Navigation on accept happens in `+todo--browse', not here, because
consult invokes 'exit before 'return."
  (let ((opened nil)
        (orig-config (current-window-configuration))
        (overlay nil))
    (lambda (action cand)
      (when (overlayp overlay)
        (delete-overlay overlay)
        (setq overlay nil))
      (pcase action
        ('preview
         ;; Consult invokes us inside `with-selected-window' on the original
         ;; window, so `selected-window' here is already the preview window.
         (cond
          ((null cand)
           (set-window-configuration orig-config))
          (t
           (when-let* ((entry (+todo--entry cand))
                       (file  (plist-get entry :file))
                       (line  (plist-get entry :line))
                       (resolved (+todo--resolve-buffer file))
                       (buf   (car resolved)))
             (when (cdr resolved) (push buf opened))
             (+todo--goto-line buf line)
             (setq overlay (+todo--make-line-overlay))))))
        ('exit
         (set-window-configuration orig-config)
         (dolist (buf opened)
           (when (buffer-live-p buf)
             (kill-buffer buf))))))))

(defun +todo--browse (collect-fn prompt)
  "Collect candidates with COLLECT-FN, browse with consult, then jump."
  (require 'consult)
  (let* ((+todo--lookup (make-hash-table :test 'equal))
         (cands (funcall collect-fn)))
    (if (null cands)
        (message "No TODOs found")
      (when-let* ((selected (consult--read
                             (+todo--by-keyword cands)
                             :prompt prompt
                             :category 'consult-location
                             :require-match t
                             :sort nil
                             :group #'+todo--group
                             :state (+todo--state)
                             :preview-key 'any))
                  (entry (+todo--entry selected))
                  (file  (plist-get entry :file))
                  (line  (plist-get entry :line)))
        (cond
         ((file-exists-p file) (find-file file))
         ((get-buffer file)    (pop-to-buffer-same-window (get-buffer file))))
        (goto-char (point-min))
        (forward-line (1- line))
        (recenter)))))

;;;###autoload
(defun +todo/in-buffer ()
  "Browse TODO-like keywords in the current buffer."
  (interactive)
  (let ((buf (current-buffer)))
    (+todo--browse (lambda () (+todo--buffer-collect buf))
                   (format "TODOs in %s: " (buffer-name buf)))))

;;;###autoload
(defun +todo/in-directory (dir)
  "Browse TODO-like keywords under DIR."
  (interactive (list (read-directory-name "Search TODOs in: " nil nil t)))
  (+todo--browse (lambda () (+todo--rg-collect dir))
                 (format "TODOs in %s: " (abbreviate-file-name dir))))

;;;###autoload
(defun +todo/in-project ()
  "Browse TODO-like keywords in the current Projectile project."
  (interactive)
  (require 'projectile)
  (let ((root (or (projectile-project-root)
                  (user-error "Not inside a project"))))
    (+todo--browse (lambda () (+todo--rg-collect root))
                   (format "TODOs in %s: "
                           (file-name-nondirectory (directory-file-name root))))))

(after! transient
  (transient-define-prefix +todo/menu ()
    "Browse TODO-like keywords."
    ["TODOs"
     ("b" "In buffer"     +todo/in-buffer)
     ("d" "In directory"  +todo/in-directory)
     ("p" "In project"    +todo/in-project)]))

(map! :leader
      :desc "TODOs" "s t" #'+todo/menu)
