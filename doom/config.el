(load! "+utils")

(setq user-full-name "Daniel Pavalache"
    user-mail-address "danielpavalache27@gmail.com")

(setq doom-font (font-spec :family "FiraCode Nerd Font" :size 18 :weight 'semi-light)
    doom-variable-pitch-font (font-spec :family "FiraCode Nerd Font" :size 20))

(setq doom-theme 'modus-vivendi)
(setq fancy-splash-image "~/.config/doom/emacs.tiff")
(setq display-line-numbers-type 'relative)
(setq ns-use-native-fullscreen t)
(setq delete-by-moving-to-trash t)

(setq-default tab-width 4)
(setq-default evil-shift-width 4)
(setq-default standard-indent 4)
(setq-default indent-tabs-mode nil)

(setq elfeed-feeds
    '("https://hnrss.org/frontpage"
         "https://lobste.rs/rss"
         "https://programming.dev/feeds/c/programming.xml"
         ))

(setq python-shell-interpreter "uv"
    python-shell-interpreter-args "run ipython -i --simple-prompt --InteractiveShell.display_page=True")

(map!
    "C-x C-x" #'other-window-prefix

    :map dired-mode-map
    :n "K" #'dired-do-kill-lines

    :leader
    :desc "Create project" "p n" #'my/create-project
    (:prefix "TAB"
        :desc "Switch to other workspace" "RET" #'+workspace/other))

(after! evil
    (defalias #'forward-evil-word #'forward-evil-symbol)
    (setq evil-symbol-word-search t))

(after! treesit
    (my/set-all-ts-indent)
    (add-hook 'after-load-functions
        (lambda (_file)
            (my/set-all-ts-indent))))

(after! projectile
    (setq projectile-auto-cleanup-known-projects t))

(when (eq system-type 'darwin)
    (after! consult
        (setq consult-locate-args "mdfind -name")))

(set-popup-rule! "^\\*compilation" :vslot -2 :size 0.3 :autosave t :quit t :ttl nil)

(load! "+git")
(load! "+org")
(load! "+todo")
(load! "+lsp")
(load! "+compilation")
(load! "+hexl")
