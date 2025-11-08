(setq user-full-name "Daniel Pavalache"
      user-mail-address "danielpavalache27@gmail.com")

(setq doom-font (font-spec :family "FiraCode Nerd Font" :size 18 :weight 'semi-light)
     doom-variable-pitch-font (font-spec :family "FiraCode Nerd Font" :size 20))

(setq doom-theme 'doom-one)

(setq display-line-numbers-type 'relative)

(setq org-directory "~/org/")

(map!
  ;; Make gj/gk move by *wrapped* (visual) lines
  :nv "gj" #'evil-next-visual-line
  :nv "gk" #'evil-previous-visual-line
  :o  "gj" #'evil-next-visual-line
  :o  "gk" #'evil-previous-visual-line

  ;; Leader keybindings
  (:leader
    ;; SPC SPC → switch workspace buffer (via Consult)
    :desc "Switch workspace buffer" "SPC" #'consult-buffer

    ;; SPC s ... → search & file operations
    (:prefix ("s" . "search")
      ;; SPC s f → jump to file in project
      :desc "Find file in project" "f" #'projectile-find-file

      ;; SPC s g → search in current directory
      :desc "Search in current directory" "g" #'+default/search-cwd

      ;; SPC s G (Shift-g) → search in another directory
      :desc "Search in another directory" "G" #'+default/search-other-cwd)))

;; Prefer tree-sitter modes where available
(setq major-mode-remap-alist
      '((bash-mode          . bash-ts-mode)
        (js2-mode           . js-ts-mode)
        (typescript-mode     . typescript-ts-mode)
        (json-mode           . json-ts-mode)
        (python-mode         . python-ts-mode)
        (css-mode            . css-ts-mode)
        (yaml-mode           . yaml-ts-mode)
        (c-mode              . c-ts-mode)
        (c++-mode            . c++-ts-mode)
        (go-mode             . go-ts-mode)
        (rust-mode           . rust-ts-mode)
        (toml-mode           . toml-ts-mode)))

(setq elfeed-feeds
      '("https://news.ycombinator.com/rss"
        "https://lobste.rs/rss"))

(after! org
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
        :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                        "#+title: ${title}\n#+filetags: :inbox:\n")
        :unnarrowed t))))

(display-time-mode t)

(customize-set-variable 'display-time-string-forms
  '((propertize (format-time-string "%a %H:%M" now)
                'help-echo (format-time-string "%a, %b %e %Y" now))))
