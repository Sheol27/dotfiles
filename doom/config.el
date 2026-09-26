(load! "+utils")

(setq user-full-name "Daniel Pavalache"
    user-mail-address "danielpavalache27@gmail.com")

(setq doom-font (font-spec :family "FiraCode Nerd Font" :size 18 :weight 'semi-light)
    doom-variable-pitch-font (font-spec :family "FiraCode Nerd Font" :size 20))

(setq doom-theme 'modus-vivendi)
(setq fancy-splash-image "~/.config/doom/dragon.svg")
(setq display-line-numbers-type 'relative)
(setq ns-use-native-fullscreen t)
(setq delete-by-moving-to-trash t)

(setq gcmh-low-cons-threshold (* 16 1024 1024))

(setq-default tab-width 4)
(setq-default evil-shift-width 4)
(setq-default standard-indent 4)
(setq-default indent-tabs-mode nil)

(setq elfeed-feeds
    '("https://hnrss.org/frontpage"
         "https://lobste.rs/rss"
         "https://programming.dev/feeds/c/programming.xml"
         ))

(after! python
    (setq python-shell-interpreter "uv"
        python-shell-interpreter-args
        "run --quiet --with ipython ipython -i --simple-prompt --InteractiveShell.display_page=True"
        python-shell-dedicated 'project)
    (add-to-list 'python-shell-completion-native-disabled-interpreters "uv"))

(after! clojure-ts-mode
    (setq +eval-repl-handler-alist
        (assq-delete-all 'clojurec-ts-mode +eval-repl-handler-alist))
    (set-repl-handler! 'clojure-ts-clojurec-mode #'+clojure/open-repl :persist t))

(map!
    "C-x C-x" #'other-window-prefix

    :map dired-mode-map
    :n "K" #'dired-do-kill-lines

    :leader
    :desc "Create project" "p n" #'my/create-project
    (:prefix "TAB"
        :desc "Switch to other workspace" "RET" #'+workspace/other))

(after! evil
    (map! :n "j" #'evil-next-visual-line
        :n "k" #'evil-previous-visual-line)
    (defalias #'forward-evil-word #'forward-evil-symbol)
    (setq evil-symbol-word-search t))

(after! treesit
    (my/set-all-ts-indent)
    (add-hook 'after-load-functions
        (lambda (file)
            (when (string-match-p "-ts-mode" file)
                (my/set-all-ts-indent)))))

(after! projectile
    (setq projectile-auto-cleanup-known-projects t))

(when (eq system-type 'darwin)
    (after! consult
        (setq consult-locate-args "mdfind -name")))

(set-popup-rule! "^\\*compilation" :vslot -2 :size 0.3 :autosave t :quit t :ttl nil)

(defun my/ghostel-buffer-name (&optional prefix suffix project?)
    (format "*%sghostel%s%s<%s>*"
        (or prefix "")
        (or suffix "")
        (if project?
            (concat ":" (or (doom-project-name)
                            (file-name-nondirectory
                                (directory-file-name default-directory))))
            "")
        (if (bound-and-true-p persp-mode)
            (safe-persp-name (get-current-persp))
            "main")))

(defun +ghostel/toggle (&optional arg)
    (interactive "P")
    (dlet ((default-directory (or (doom-project-root) default-directory)))
        (dlet ((ghostel-buffer-name (my/ghostel-buffer-name "doom:" "-popup" t))
                  ghostel-buffer-name-function
                  ghostel-query-before-killing
                  confirm-kill-processes
                  current-prefix-arg)
            (when arg
                (let ((buffer (get-buffer ghostel-buffer-name))
                         (window (get-buffer-window ghostel-buffer-name)))
                    (when (buffer-live-p buffer)
                        (kill-buffer buffer))
                    (when (window-live-p window)
                        (delete-window window))))
            (if-let* ((win (get-buffer-window ghostel-buffer-name)))
                (delete-window win)
                (with-current-buffer (ghostel)
                    ;; Don't rename the buffer or the popup manager may lose track of it.
                    (setq-local ghostel-buffer-name-function nil)
                    (set-window-dedicated-p (get-buffer-window) t)
                    (current-buffer))))))

(defun +ghostel/here ()
    "Open a new ghostel buffer in the current window."
    (interactive)
    (dlet ((ghostel-buffer-name
               (generate-new-buffer-name (my/ghostel-buffer-name))))
        (switch-to-buffer (save-window-excursion (ghostel)))))

(when (eq system-type 'darwin)
    (defun my/native-comp-skip-on-battery-p ()
        (and (not native-comp-async-on-battery-power)
            (require 'battery nil t)
            battery-status-function
            (member (cdr (assq ?L (funcall battery-status-function)))
                '("off-line" "BAT" "Battery"))))
    (advice-add 'native--compile-skip-on-battery-p :override
        #'my/native-comp-skip-on-battery-p))

(defun my/silicon-region (beg end)
    "Render the region as an image with silicon and copy it to the clipboard."
    (interactive "r")
    (let* ((lang (or (and buffer-file-name (file-name-extension buffer-file-name))
                     (replace-regexp-in-string
                         "\\(-ts\\)?-mode\\'" "" (symbol-name major-mode))))
              (file (make-temp-file "silicon-" nil ".png")))
        (call-process-region beg end "silicon" nil "*silicon*" nil
            "-l" lang
            "--theme" "modus-vivendi"
            "--no-line-number"
            "--no-round-corner"
            "--no-window-controls"
            "--pad-horiz" "0"
            "--pad-vert" "0"
            "--background" "#00000000"
            "-o" file
            "--to-clipboard")
        (message "Screenshot copied to clipboard (also saved to %s)" file)))

(defun my/cider-scratch-aliases (orig &rest args)
  (let ((cider-clojure-cli-aliases
         (if (clojure-project-dir)
             cider-clojure-cli-aliases
           ":scratch")))
    (apply orig args)))

(advice-add 'cider-jack-in-clj :around #'my/cider-scratch-aliases)

(setq cider-allow-jack-in-without-project t)

(defun my/clojure-buffer-p ()
  (derived-mode-p 'clojure-mode 'clojure-ts-mode))

(defun my/lispy-cider-eval ()
  (interactive)
  (if (my/clojure-buffer-p)
      (if (looking-at lispy-left)
          (save-excursion
            (forward-sexp)
            (cider-eval-last-sexp))
        (cider-eval-last-sexp))
    (call-interactively #'lispy-eval)))

(defun my/lispy-cider-eval-defun ()
  (interactive)
  (if (my/clojure-buffer-p)
      (cider-eval-defun-at-point)
    (call-interactively #'lispy-eval-and-insert)))

(after! lispy
  (lispy-define-key lispy-mode-map "e" #'my/lispy-cider-eval)
  (lispy-define-key lispy-mode-map "E" #'my/lispy-cider-eval-defun))

(load! "+git")
(load! "+org")
(load! "+todo")
(load! "+lsp")
(load! "+hexl")
