;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; --- Custom Keybindings ---
(map!
  ;; "-" opens Dired in current directory
  :n "-" #'dired-jump

  ;; Leader keybindings
  (:leader
    ;; SPC - → find file (in current directory)
    :desc "Find file" "-" #'find-file

    ;; SPC SPC → switch workspace buffer (via Consult)
    :desc "Switch workspace buffer" "SPC" #'consult-buffer

    :desc "Smart compile" "c c" #'custom/compile-in-correct-directory

    ;; SPC s ... → search & file operations
    (:prefix ("s" . "search")
      ;; SPC s f → jump to file in project
      :desc "Find file in project" "f" #'projectile-find-file

      ;; SPC s g → search in current directory
      :desc "Search in current directory" "g" #'+default/search-cwd

      ;; SPC s G (Shift-g) → search in another directory
      :desc "Search in another directory" "G" #'+default/search-other-cwd)))

(defun custom/compile-in-correct-directory ()
  "Run `compile` with working directory intelligently chosen.
If in a Dired buffer, use that directory.
Otherwise, use the project root if available."
  (interactive)
  (let* ((default-dir
           (cond
            ;; If in dired, use that directory
            ((derived-mode-p 'dired-mode)
             (dired-current-directory))
            ;; If in a project, use project root
            ((project-current)
             (project-root (project-current)))
            ;; Fallback: current directory
            (t default-directory))))
    (let ((default-directory default-dir))
      (call-interactively #'compile))))


(after! lsp-mode
  (setq lsp-diagnostics-provider :none))
(setq display-line-numbers-type 'relative)








(defun my/compile-history-edit ()
  "Open the compile history in an editable buffer."
  (interactive)
  (let ((buf (get-buffer-create "*Compile History*")))
    (with-current-buffer buf
      (erase-buffer)
      (insert (mapconcat #'identity compile-history "\n"))
      (setq-local my/compile-history-mode t)
      (setq-local buffer-read-only nil))
    (switch-to-buffer buf)))

(defun my/compile-history-save-and-run ()
  "Save changes in the compile history buffer and run compile."
  (interactive)
  (when (eq major-mode 'fundamental-mode)
    (setq compile-history
          (split-string (buffer-string) "\n" t))
    (call-interactively #'compile)))

(define-key global-map (kbd "C-c h") #'my/compile-history-edit)
