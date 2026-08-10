;;; doom/+utils.el -*- lexical-binding: t; -*-

(defun my/create-dir-with-remote-connection ()
  "Create .dir-locals.el with ssh-deploy config using TRAMP completion."
  (interactive)
  (let* ((project-root (projectile-project-root))
         (project-name (file-name-nondirectory (directory-file-name project-root)))
         (remote-base (read-file-name "Remote root: " "/ssh:"))
         (remote-full (concat (file-name-as-directory remote-base) project-name "/"))
         (local-abbrev (abbreviate-file-name (file-name-as-directory project-root)))
         (dir-locals-file (expand-file-name ".dir-locals.el" project-root))
         (content (format "((nil . ((ssh-deploy-root-local . %S)
         (ssh-deploy-root-remote . %S)
         (ssh-deploy-on-explicit-save . 1)
         (ssh-deploy-exclude-list . (\".git\" \".DS_Store\" \"node_modules\" \"__pycache__\" \".venv\" \"*.pyc\")))))\n"
                          local-abbrev
                          remote-full)))
    (when (or (not (file-exists-p dir-locals-file))
              (yes-or-no-p ".dir-locals.el exists. Overwrite? "))
      (write-region content nil dir-locals-file)
      (hack-dir-local-variables-non-file-buffer)
      (message "ssh-deploy: %s → %s" local-abbrev remote-full))))


(defun my/ssh-deploy-rsync ()
  "Upload project to remote via rsync using ssh-deploy dir-local variables.
Unlike ssh-deploy's copy-directory, this actually respects the exclude list."
  (interactive)
  (unless (and (bound-and-true-p ssh-deploy-root-local)
               (bound-and-true-p ssh-deploy-root-remote))
    (user-error "ssh-deploy roots not configured for this project"))
  (let* ((local (file-name-as-directory (expand-file-name ssh-deploy-root-local)))
         (remote ssh-deploy-root-remote)
         (parsed
          (if (string-match "\\`/ssh[x]?:\\([^:|#]+\\)\\(?:#\\([0-9]+\\)\\)?:\\(.*\\)" remote)
              (list (concat (match-string 1 remote) ":" (match-string 3 remote))
                    (match-string 2 remote))
            (user-error "Cannot parse Tramp path: %s" remote)))
         (remote-dest (nth 0 parsed))
         (port (nth 1 parsed))
         (excludes (mapcar (lambda (pat)
                            (setq pat (replace-regexp-in-string "\\\\\\." "." pat))
                            (replace-regexp-in-string "\\$$" "" pat))
                          (bound-and-true-p ssh-deploy-exclude-list)))
         (cmd (concat "rsync -avz --progress"
                      (if port (format " -e 'ssh -p %s'" port) "")
                      (mapconcat (lambda (e) (format " --exclude='%s'" e)) excludes "")
                      " " (shell-quote-argument local)
                      " " remote-dest)))
    (message "rsync: %s → %s" (abbreviate-file-name local) remote-dest)
    (async-shell-command cmd "*rsync-deploy*")))

(defun my/repo-name-from-url (url)
  "Infer repo directory name from git remote URL."
  (let* ((url (replace-regexp-in-string "/\\'" "" url))
         (last-part (car (last (split-string url "[:/]" t)))))
    (replace-regexp-in-string "\\.git\\'" "" last-part)))

(defun my/create-project (&optional git-url)
  "Create a local project, or clone a git project if GIT-URL is provided.
Interactively, leave the URL empty to create+init."
  (interactive
   (list
    (let ((s (string-trim (read-string "Git remote URL (empty to init): "))))
      (unless (string= s "") s))))

  (let* ((choices '("Projects" "Dev" "Software"))
         (base-dir (completing-read "Choose: " choices nil t))
         (default-name (and git-url (my/repo-name-from-url git-url)))
         (project-dir (read-string "Project name: " default-name))
         (r-path (format "%s/%s" base-dir project-dir))
         (full-path (expand-file-name r-path "~"))
         (parent-dir (file-name-directory (directory-file-name full-path))))

    (if (file-exists-p full-path)
        (message "Path %s already exists" full-path)
      (if git-url
          ;; Clone branch
          (progn
            (make-directory parent-dir t)
            (message "Cloning %s into %s..." git-url full-path)
            (redisplay)
            (if (zerop (magit-call-git "clone" "--depth" "1" git-url full-path))
                (progn
                  (projectile-add-known-project full-path)
                  (projectile-invalidate-cache nil)
                  (projectile-switch-project-by-name full-path)
                  (message "Cloned %s into %s" git-url full-path))
              (message "Failed to clone %s" git-url)))
        ;; Init branch
        (progn
          (make-directory full-path t)
          (message "Initializing git repo in %s..." full-path)
          (redisplay)
          (if (zerop (magit-call-git "init" full-path))
              (progn
                (projectile-add-known-project full-path)
                (projectile-invalidate-cache nil)
                (projectile-switch-project-by-name full-path)
                (message "Initialized git repo in %s" full-path))
            (message "Failed to initialize git repo in %s" full-path)))))))

(defun my/set-all-ts-indent()
  (mapatoms
   (lambda (sym)
     (when (and (boundp sym)
                (string-suffix-p "-ts-mode-indent-offset"
                                 (symbol-name sym)))
       (set sym 4)))))
