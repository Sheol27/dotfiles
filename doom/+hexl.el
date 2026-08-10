;;; doom/+hexl.el -*- lexical-binding: t; -*-

(after! hexl
  (defun +hexl-byte-face (byte)
    "Return a face for a single hex byte string like \"7f\"."
    (let ((b (string-to-number byte 16)))
      (cond ((zerop b)                     'shadow)                ; 00
            ((= b #xff)                    'error)                 ; ff
            ((and (>= b #x20) (<= b #x7e)) 'success)               ; printable ASCII
            ((< b #x20)                    'font-lock-comment-face) ; control bytes
            (t                             'font-lock-keyword-face)))) ; high bytes 0x80+

  (defun +hexl-byte-matcher (limit)
    "Match a byte only inside the hex area, skipping address + ASCII columns."
    (let (found)
      (while (and (not found)
                  (re-search-forward "[0-9a-f][0-9a-f]" limit t))
        (let ((col (- (match-beginning 0) (line-beginning-position))))
          ;; default hexl-bits=16: hex area spans cols 10..48
          (when (and (>= col 10) (< col 50))
            (setq found t))))
      found))

  (defun +hexl-fontify ()
    (font-lock-add-keywords nil
      '((+hexl-byte-matcher
         (0 (+hexl-byte-face (match-string 0)) t))))
    (font-lock-mode 1)
    (font-lock-flush))

  (add-hook 'hexl-mode-hook #'+hexl-fontify))
