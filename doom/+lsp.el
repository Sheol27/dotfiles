;;; +lsp.el -*- lexical-binding: t; -*-

(after! corfu
  (setq corfu-auto nil)
  (setq tab-always-indent 'complete))

(after! eglot
  (setq eglot-stay-out-of '(flymake))
  (setq eglot-ignored-server-capabilities
        '(:inlayHintProvider :signatureHelpProvider)))

(after! eldoc
  (global-eldoc-mode -1))
