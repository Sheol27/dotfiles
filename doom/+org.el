;;; +org.el -*- lexical-binding: t; -*-

(after! org
    (setq org-directory "~/org/")

    ;; Better visual hierarchy
    (setq org-startup-indented t)
    (setq org-startup-folded 'content)

    (setq org-refile-use-outline-path 'file)
    (setq org-outline-path-complete-in-steps nil)
    (setq org-refile-allow-creating-parent-nodes 'confirm)

    (setq org-log-done 'time)
    (setq org-log-into-drawer t)
    ;; Doom's default "t" template uses a checkbox ("* [ ]"); use a TODO keyword instead.
    (setf (alist-get "t" org-capture-templates nil nil #'equal)
        '("Personal todo" entry
             (file+headline +org-capture-todo-file "Inbox")
             "* TODO %?\n%i\n%a" :prepend t))
    (setq org-capture-templates
        (append org-capture-templates
            '(("w" "web site" entry (file+headline org-default-notes-file "Inbox")
                  "* TODO [[%:link][%:description]] :inbox:web:\n:PROPERTIES:\n:Captured: %U\n:END:\n\n%i"
                  :immediate-finish t :empty-lines 1)
                 ("i" "Inbox" entry
                     (file "~/org/inbox.org")
                     "* INBOX %?\n%U\n%i"
                     :empty-lines 1)
                 )))

    (setq org-todo-keywords
        '((sequence "INBOX(i)"      ; Uncategorized, needs processing
              "TODO(t)"       ; Ready to work on
              "NEXT(n)"       ; Next action (high priority)
              "WAIT(w@/!)"    ; Waiting on someone/something
              "HOLD(h@/!)"    ; On hold (blocked)
              "|"
              "DONE(d!)"      ; Completed
              "KILL(k@)")))   ; Cancelled

    ;; Faces for TODO keywords
    (setq org-todo-keyword-faces
        '(("INBOX" . (:foreground "#b16286" :weight bold))
             ("TODO"  . (:foreground "#fabd2f" :weight bold))
             ("NEXT"  . (:foreground "#fe8019" :weight bold))
             ("WAIT"  . (:foreground "#83a598" :weight bold))
             ("HOLD"  . (:foreground "#928374" :weight bold))
             ("DONE"  . (:foreground "#8ec07c" :weight bold))
             ("KILL"  . (:foreground "#928374" :weight bold :strike-through t))))

    (setq org-tag-alist
        '(;; Context tags (WHERE you can do this)
             (:startgroup)
             ("@work"    . ?w)
             ("@home"    . ?h)
             ("@errand"  . ?e)
             ("@anywhere". ?a)
             (:endgroup)
             ;; Type tags
             ("code"     . ?c)
             ("review"   . ?r)
             ("meeting"  . ?m)
             ("bug"      . ?b)
             ("feature"  . ?f)
             ("devops"   . ?d)
             ("learning" . ?l)
             ("admin"    . ?A))))


(defun my/org-roam-update-last-modified ()
    (when (and (derived-mode-p 'org-mode)
              (buffer-file-name)
              (string-prefix-p (file-truename org-roam-directory)
                  (file-truename (buffer-file-name))))
        (save-excursion
            (goto-char (point-min))
            (let ((ts (format-time-string "[%Y-%m-%d %a %H:%M]")))
                (when (re-search-forward "^:PROPERTIES:$" nil t)
                    (if (re-search-forward "^:LAST_MODIFIED:.*$" nil t)
                        (replace-match (concat ":LAST_MODIFIED: " ts) t t)
                        (when (re-search-forward "^:END:$" nil t)
                            (beginning-of-line)
                            (insert ":LAST_MODIFIED: " ts "\n"))))))))


(after! org-roam
    (add-hook 'before-save-hook #'my/org-roam-update-last-modified)
    (setq org-roam-dailies-capture-templates
        '(("d" "default" entry "* %<%H:%M>: %?"
              :if-new (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n"))))
    (setq org-roam-capture-templates
        '(("d" "default" plain "%?"
              :if-new
              (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                  ":PROPERTIES:\n:ID: %(org-id-new)\n:CREATED: %U\n:LAST_MODIFIED: %U\n:END:\n#+title: ${title}\n#+filetags: :inbox:\n\n")
              :unnarrowed t))))

(after! ox-latex
    (add-to-list 'org-latex-packages-alist '("" "hyperref" nil))
    (setq org-latex-create-formula-image-program 'dvisvgm)
    (setq org-preview-latex-default-process 'dvisvgm)
    (setq org-latex-hyperref-template
        "\\hypersetup{hidelinks}\n"))

(setq org-latex-create-formula-image-program 'dvisvgm)
(setq org-preview-latex-default-process 'dvisvgm)
(setq org-latex-src-block-backend 'engraved)

;; Shorten org-attach URL filenames: strip query string from URL
(after! org-attach
    (defun my/org-attach-url-strip-query (orig-fun url &rest args)
        "Call ORIG-FUN with URL but strip ?query=… so filename is shorter."
        (let* ((parsed (url-generic-parse-url url))
                  (fname  (url-filename parsed))
                  (q-pos  (and fname (string-match "\\?" fname))))
            (when q-pos
                (setf (url-filename parsed)
                    (substring fname 0 q-pos))
                (setq url (url-recreate-url parsed)))
            (apply orig-fun url args)))

    (advice-add 'org-attach-url :around #'my/org-attach-url-strip-query))

(after! citar
    (setq! citar-bibliography (directory-files "~/Documents/Literature/" t "\\.bib$"))
    (setq! org-cite-global-bibliography citar-bibliography)
    (setq citar-templates
        '((main . "${author editor:30%sn}     ${date year issued:4}     ${title:48}")
             (suffix . "          ${=key= id:15}    ${=type=:12}    ${tags groups keywords:*}")
             (preview . "${author editor:%etal} (${year issued date}) ${title}, ${journal journaltitle publisher container-title collection-title keywords}.\n")
             (note . "Notes on ${author editor:%etal}, ${title}")))
    (setq! org-cite-insert-processor 'citar)
    (setq! org-cite-follow-processor 'citar)
    (setq! org-cite-activate-processor 'citar)
    (setq! citar-org-roam-note-title-template "${title}\n#+authors: ${author}\n#+filetags: :paper:"))

(map! :map org-mode-map
    :leader
    :prefix "n"
    "B" #'citar-org-roam-open-current-refs)
