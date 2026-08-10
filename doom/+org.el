;;; +org.el -*- lexical-binding: t; -*-

(use-package! org-super-agenda
  :after org-agenda
  :init
  (org-super-agenda-mode)
  :config
  (setq org-super-agenda-header-map (make-sparse-keymap)))


(setq org-directory "~/org/")
(setq org-gtd-directory (concat org-directory "gtd/"))

;; =============================================================================
;; CORE ORG SETTINGS
;; =============================================================================

(after! org
  ;; Files for agenda
  (setq org-agenda-files (list (concat org-gtd-directory "inbox.org")
                               (concat org-gtd-directory "projects.org")
                               (concat org-gtd-directory "someday.org")))

  ;; Default notes file (inbox)
  (setq org-default-notes-file (concat org-gtd-directory "inbox.org"))

  ;; Refile targets - this is where you process inbox items TO
  (setq org-refile-targets `((,(concat org-gtd-directory "projects.org") :maxlevel . 3)
                             (,(concat org-gtd-directory "someday.org") :maxlevel . 2)))
  (setq org-refile-use-outline-path 'file)
  (setq org-outline-path-complete-in-steps nil)
  (setq org-refile-allow-creating-parent-nodes 'confirm)

  ;; Log when tasks are completed
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)

  ;; =============================================================================
  ;; TODO KEYWORDS
  ;; =============================================================================
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

  ;; =============================================================================
  ;; TAGS
  ;; =============================================================================
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
          ("admin"    . ?A)))

  ;; =============================================================================
  ;; CAPTURE TEMPLATES
  ;; =============================================================================
  ;; All captures go to INBOX - process later by refiling
  (setq org-capture-templates
        `(("i" "Inbox" entry
           (file ,(concat org-gtd-directory "inbox.org"))
           "* INBOX %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n"
           :empty-lines 1)

          ("t" "Task with context" entry
           (file ,(concat org-gtd-directory "inbox.org"))
           "* INBOX %?\n:PROPERTIES:\n:CREATED: %U\n:CONTEXT: %a\n:END:\n"
           :empty-lines 1)

          ("c" "Code task" entry
           (file ,(concat org-gtd-directory "inbox.org"))
           "* INBOX %? :code:\n:PROPERTIES:\n:CREATED: %U\n:END:\n#+begin_src \n\n#+end_src"
           :empty-lines 1)

          ("b" "Bug" entry
           (file ,(concat org-gtd-directory "inbox.org"))
           "* INBOX [BUG] %? :bug:\n:PROPERTIES:\n:CREATED: %U\n:REPORTED: %^{Reported by}\n:END:\n** Description\n\n** Steps to Reproduce\n\n** Expected Behavior\n\n** Actual Behavior\n"
           :empty-lines 1)

          ("m" "Meeting notes" entry
           (file ,(concat org-gtd-directory "inbox.org"))
           "* INBOX Meeting: %? :meeting:\n:PROPERTIES:\n:CREATED: %U\n:ATTENDEES: \n:END:\n** Agenda\n\n** Notes\n\n** Action Items\n"
           :empty-lines 1)

          ("r" "Review request" entry
           (file ,(concat org-gtd-directory "inbox.org"))
           "* INBOX Review: %? :review:\n:PROPERTIES:\n:CREATED: %U\n:PR_LINK: \n:END:\n"
           :empty-lines 1)
          ("w" "Web site" entry
           (file+headline org-default-notes-file "Inbox")
           "* TODO [[%:link][%:description]] :inbox:web:\n:PROPERTIES:\n:Captured: %U\n:END:\n\n%i"
           :immediate-finish t
           :empty-lines 1))))

;; =============================================================================
;; ORG-SUPER-AGENDA CONFIGURATION
;; =============================================================================

(use-package! org-super-agenda
  :after org-agenda
  :config
  (org-super-agenda-mode)

  (setq org-agenda-custom-commands
        '(;; ========== DAILY DRIVER ==========
          ("d" "Daily Dashboard"
           ((agenda "" ((org-agenda-span 'day)
                        (org-agenda-start-day nil)
                        (org-agenda-start-on-weekday nil)
                        (org-super-agenda-groups
                         '((:name "⏰ Schedule"
                            :time-grid t
                            :scheduled today)
                           (:name "📅 Due Today"
                            :deadline today)
                           (:name "⚠️ Overdue"
                            :deadline past)
                           (:name "🔥 Reschedule"
                            :scheduled past)))))
            (alltodo "" ((org-agenda-overriding-header "")
                         (org-super-agenda-groups
                          '((:name "📥 Inbox - Process Me!"
                             :todo "INBOX"
                             :order 1)
                            (:name "🎯 Next Actions"
                             :todo "NEXT"
                             :order 2)
                            (:name "⏳ Waiting On"
                             :todo "WAIT"
                             :order 3)
                            (:name "💻 Code Tasks"
                             :and (:tag "code" :todo "TODO")
                             :order 10)
                            (:name "👀 Code Reviews"
                             :tag "review"
                             :order 11)
                            (:name "🐛 Bugs"
                             :tag "bug"
                             :order 12)
                            (:name "📚 Learning"
                             :tag "learning"
                             :order 20)
                            (:name "🏠 Personal"
                             :tag "@home"
                             :order 30)
                            (:name "🏃 Errands"
                             :tag "@errand"
                             :order 31)
                            (:discard (:todo "HOLD"))))))))

          ;; ========== INBOX PROCESSING ==========
          ("i" "Inbox Processing"
           ((alltodo "" ((org-agenda-overriding-header "📥 INBOX - Items to Process & Refile")
                         (org-super-agenda-groups
                          '((:name "Needs Processing"
                             :todo "INBOX")
                            (:discard (:anything t))))))))

          ;; ========== WORK FOCUS ==========
          ("w" "Work Focus"
           ((alltodo "" ((org-agenda-overriding-header "💼 Work Tasks")
                         (org-super-agenda-groups
                          '((:name "🔥 Next Actions"
                             :and (:todo "NEXT" :tag "@work"))
                            (:name "👀 Reviews Pending"
                             :and (:tag "review" :todo ("TODO" "NEXT")))
                            (:name "🐛 Bugs to Fix"
                             :and (:tag "bug" :todo ("TODO" "NEXT")))
                            (:name "✨ Features"
                             :and (:tag "feature" :todo ("TODO" "NEXT")))
                            (:name "🔧 DevOps"
                             :and (:tag "devops" :todo ("TODO" "NEXT")))
                            (:name "⏳ Waiting"
                             :and (:todo "WAIT" :tag "@work"))
                            (:name "📋 Backlog"
                             :and (:tag "@work" :todo "TODO"))
                            (:discard (:anything t))))))))

          ;; ========== WEEKLY REVIEW ==========
          ("W" "Weekly Review"
           ((agenda "" ((org-agenda-span 'week)
                        (org-agenda-start-day nil)
                        (org-agenda-start-on-weekday 1)))
            (alltodo "" ((org-agenda-overriding-header "")
                         (org-super-agenda-groups
                          '((:name "📥 Inbox (Process First!)"
                             :todo "INBOX")
                            (:name "🔥 Stuck/Stale (No Progress)"
                             :todo "HOLD")
                            (:name "⏳ Waiting - Follow Up?"
                             :todo "WAIT")
                            (:name "🎯 Active Next Actions"
                             :todo "NEXT")
                            (:name "📋 All TODOs by Category"
                             :auto-category t)))))))

          ;; ========== PROJECTS OVERVIEW ==========
          ("p" "Projects"
           ((alltodo "" ((org-agenda-overriding-header "🗂️ Projects Overview")
                         (org-agenda-files (list (concat org-gtd-directory "projects.org")))
                         (org-super-agenda-groups
                          '((:auto-parent t))))))))))

;; =============================================================================
;; ADDITIONAL SETTINGS
;; =============================================================================

(after! org
  ;; Better visual hierarchy
  (setq org-startup-indented t)
  (setq org-startup-folded 'content)

  ;; Archive location
  (setq org-archive-location (concat org-gtd-directory "archive.org::datetree/")))
;;; org-task-config.el ends here
(setq org-agenda-prefix-format
      '((agenda . " %i %-20:c%?-12t% s")
        (todo   . " %i %-20:c")
        (tags   . " %i %-20:c")
        (search . " %i %-20:c")))


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

(add-hook 'before-save-hook #'my/org-roam-update-last-modified)

(after! org
  ;; add completion timestamp to TODO)
  (setq org-log-done t)
  (add-to-list 'org-capture-templates
               '("w" "web site" entry (file+headline org-default-notes-file "Inbox")
                 "* TODO [[%:link][%:description]] :inbox:web:\n:PROPERTIES:\n:Captured: %U\n:END:\n\n%i"
                 :immediate-finish t :empty-lines 1)))

(after! org-roam
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

(use-package! org-alert
  :commands (org-alert-check)
  :config
  (setq org-alert-interval 300
        org-alert-notify-cutoff 10
        org-alert-notify-after-event-cutoff 10)
  (org-alert-enable))

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
