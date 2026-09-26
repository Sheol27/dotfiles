;;; +git.el -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'subr-x)

(defun my/worktree-root (path)
    (file-truename
        (directory-file-name (expand-file-name path))))

(defun my/git-linked-worktree-p (path)
    "Return non-nil if PATH is a linked git worktree, not the main checkout."
    (let* ((root (my/worktree-root path))
              (default-directory (file-name-as-directory root))
              (git-dir (ignore-errors
                           (string-trim
                               (car (process-lines "git" "rev-parse" "--git-dir")))))
              (common-dir (ignore-errors
                              (string-trim
                                  (car (process-lines "git" "rev-parse" "--git-common-dir"))))))
        (when (and git-dir common-dir)
            (let ((git-dir (expand-file-name git-dir default-directory))
                     (common-dir (expand-file-name common-dir default-directory)))
                (not (file-equal-p git-dir common-dir))))))

(defun my/worktree-workspace-name (path)
    "Compute the custom workspace name for a linked git worktree at PATH."
    (let* ((root (my/worktree-root path))
              (default-directory (file-name-as-directory root))
              (common-dir (ignore-errors
                              (string-trim
                                  (car (process-lines "git" "rev-parse" "--git-common-dir")))))
              (common-dir (and common-dir
                              (expand-file-name common-dir default-directory)))
              (repo-name
                  (if (and common-dir
                          (string= (file-name-nondirectory
                                       (directory-file-name common-dir))
                              ".git"))
                      (file-name-nondirectory
                          (directory-file-name
                              (file-name-directory
                                  (directory-file-name common-dir))))
                      (file-name-nondirectory
                          (directory-file-name root))))
              (branch (ignore-errors
                          (string-trim
                              (car (process-lines "git" "branch" "--show-current"))))))
        (format "w:%s/%s"
            repo-name
            (if (and branch (not (string-empty-p branch)))
                branch
                "detached"))))

(defun my/projectile-workspace-name (path)
    "Use Projectile's classic project naming for PATH."
    (let ((default-directory (file-name-as-directory (my/worktree-root path))))
        (or (ignore-errors (projectile-project-name))
            (file-name-nondirectory
                (directory-file-name default-directory)))))

(defun my/project-workspace-name (path)
    "Use custom naming for linked worktrees, Projectile naming otherwise."
    (if (my/git-linked-worktree-p path)
        (my/worktree-workspace-name path)
        (my/projectile-workspace-name path)))

(defun my/register-workspace-project (path)
    (set-persp-parameter '+workspace-project
        (my/worktree-root path)
        (+workspace-current)))

(defun my/open-project-in-workspace (path)
    "Open PATH in its workspace, showing only Dired."
    (let* ((root (my/worktree-root path))
              (ws-name (my/project-workspace-name root)))
        (+workspace-switch ws-name t)
        (my/register-workspace-project root)
        (delete-other-windows)
        (let ((default-directory (file-name-as-directory root)))
            (switch-to-buffer (dired-noselect root))
            (delete-other-windows))))

(setq +workspaces-switch-project-function #'dired)

(defun my/workspaces-switch-to-project-h (&optional dir)
    "Use custom workspace naming only for linked git worktrees."
    (let* ((root (my/worktree-root (or dir default-directory)))
              (ws-name (my/project-workspace-name root)))
        (+workspace-switch ws-name t)
        (my/register-workspace-project root)
        (let ((default-directory (file-name-as-directory root)))
            (unless current-prefix-arg
                (funcall +workspaces-switch-project-function root)))))

(after! persp-mode
    (setq projectile-switch-project-action
        #'my/workspaces-switch-to-project-h))


(after! magit
    (when (eq system-type 'darwin)
        (setq magit-git-executable "/opt/homebrew/bin/git"))

    (magit-add-section-hook 'magit-status-sections-hook
        #'magit-insert-worktrees
        #'magit-insert-stashes
        t)

    (defun my/magit-worktree-open-in-workspace (&optional worktree)
        (interactive
            (list
                (or (magit-section-value-if 'worktree)
                    (magit-completing-read
                        "Open worktree: "
                        (cl-delete (directory-file-name (magit-toplevel))
                            (magit-list-worktrees)
                            :test #'equal
                            :key #'car)
                        nil t))))
        (my/open-project-in-workspace worktree))

    (define-key magit-worktree-section-map (kbd "RET")
        #'my/magit-worktree-open-in-workspace)
    (define-key magit-worktree-section-map (kbd "<return>")
        #'my/magit-worktree-open-in-workspace)

    (advice-add #'magit-worktree-status :override
        #'my/magit-worktree-open-in-workspace)

    (defun my/magit-worktree-create-into-workspace (orig-fn &rest args)
        (cl-letf (((symbol-function 'magit-diff-visit-directory)
                      (lambda (dir)
                          (my/open-project-in-workspace dir))))
            (apply orig-fn args)))

    (advice-add #'magit-worktree-checkout :around
        #'my/magit-worktree-create-into-workspace)
    (advice-add #'magit-worktree-branch :around
        #'my/magit-worktree-create-into-workspace)

    (setq magit-read-worktree-directory-function
        #'magit-read-worktree-directory-offsite
        magit-read-worktree-offsite-directory
        "~/Worktrees/"))

(after! ediff
    (setq ediff-forward-word-function 'forward-char)  ;; character-level refinement
    (custom-set-faces!
        '(ediff-current-diff-A :background "#553333" :extend t)
        '(ediff-current-diff-B :background "#335533" :extend t)
        '(ediff-fine-diff-A :background "#804040" :weight bold)
        '(ediff-fine-diff-B :background "#408040" :weight bold)))

(defun +git-audit/run (cmd buf-name)
    "Run CMD in the repo root and display output in BUF-NAME."
    (let ((default-directory (magit-toplevel)))
        (unless default-directory (user-error "Not in a git repo"))
        (with-current-buffer (get-buffer-create buf-name)
            (let ((inhibit-read-only t))
                (erase-buffer)
                (insert (shell-command-to-string cmd)))
            (goto-char (point-min))
            (special-mode)
            (pop-to-buffer (current-buffer)))))

(defun +git-audit/changes ()
    (interactive)
    (+git-audit/run
        "git log --format=format: --name-only --since='1 year ago' | sort | uniq -c | sort -nr | head -20"
        "*git-audit: changes*"))

(defun +git-audit/contributors ()
    (interactive)
    (+git-audit/run
        "git shortlog -sn --no-merges HEAD"
        "*git-audit: contributors*"))

(defun +git-audit/bug-hotspots ()
    (interactive)
    (+git-audit/run
        "git log -i -E --grep='fix|bug|broken' --name-only --format='' | sort | uniq -c | sort -nr | head -20"
        "*git-audit: bug hotspots*"))

(defun +git-audit/velocity ()
    (interactive)
    (+git-audit/run
        "git log --format='%ad' --date=format:'%Y-%m' | sort | uniq -c"
        "*git-audit: velocity*"))

(defun +git-audit/firefighting ()
    (interactive)
    (+git-audit/run
        "git log --oneline --since='1 year ago' | grep -iE 'revert|hotfix|emergency|rollback'"
        "*git-audit: firefighting*"))

(after! transient
    (transient-define-prefix +git-audit/menu ()
        ["Git Audit"
            ("c" "Changes hotspots"   +git-audit/changes)
            ("w" "Who built this"   +git-audit/contributors)
            ("b" "Bug clusters"     +git-audit/bug-hotspots)
            ("v" "Commit velocity"  +git-audit/velocity)
            ("f" "Firefighting"     +git-audit/firefighting)]))

(set-popup-rule! "^\\*git-audit:" :side 'bottom :size 0.25 :select t)

(map! :leader
    :desc "Git audit" "g a" #'+git-audit/menu)
