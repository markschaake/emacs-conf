;; make sure all packages are loaded
(load-file "~/emacs.git/packages.el")

(xclip-mode 1)

(load "~/emacs.git/ai2-imports.el")

(load "~/emacs.git/local/ai2-scala-spec.el")

(set-face-attribute 'default nil :height 100)

(add-to-list 'load-path "~/emacs.git/local/")

(add-hook 'dired-load-hook
          (lambda ()
            (load "dired-x")))

(set-register ?e '(file . "~/emacs.git/.emacs"))

(set-register ?i '(file . "~/emacs.git/init.el"))

(set-register ?g '(file . "~/Dropbox/org/gtd/gtd.org"))

(winner-mode t)

;; prevent ediff to open multiple frames which is busted for some reason
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

(set-variable 'sbt:program-name "/usr/local/bin/sbt")

(setenv "PATH" (concat (getenv "PATH") ":/usr/local/bin"))
(setq exec-path (append exec-path '("/usr/local/bin")))

(setenv "PATH" (concat (getenv "PATH") ":/Library/PostgreSQL/9.4/bin"))
(setq exec-path (append exec-path '("/Library/PostgreSQL/9.4/bin")))

(add-hook 'sql-interactive-mode-hook
          (lambda ()
            (sql-set-product 'postgres)
            (toggle-truncate-lines t)))

;; imenu
(global-set-key (kbd "M-i") 'helm-imenu-in-all-buffers)
(global-set-key (kbd "C-x C-b") 'ibuffer)

;; Magit
(global-set-key "\C-xg" 'magit-status)
(require 'magit-gh-pulls)
(add-hook 'magit-mode-hook 'turn-on-magit-gh-pulls)

(global-set-key "\C-ct" 'eshell)
(eshell-git-prompt-use-theme 'git-radar)

;; Some initial langauges we want org-babel to support
(setq org-src-fontify-natively t)
(org-babel-do-load-languages
 'org-babel-load-languages
 '(
   (sh . t)
   (scala . t)
   ))

;(setq org-default-notes-file (concat org-directory "~/Dropbox/notes.org"))

;; tabs and whitespace
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq whitespace-line-column 100)
(setq whitespace-style '(face tabs trailing lines-tail space-before-tab newline indentation empty space-after-tab tab-mark newline-mark))

(global-set-key (kbd "C-j") 'newline-and-indent)

(setq sh-basic-offset 2 sh-indentation 2)

;; buffers
;; revert buffers when changed externally (like git checkout)
(global-auto-revert-mode t)
;; save backup and temp files in /temp
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; color theme
(load-theme 'zenburn t)

;; turn off the toolbar for GUI emacs
(tool-bar-mode -1)

;; ace-jump-mode key binding
(define-key global-map (kbd "C-c SPC") 'ace-jump-mode)

;; turn on ido mode for awesome interactive stuff
(ido-mode t)
(setq ido-everywhere t)
(setq ido-enable-flex-matching t)

;; turn on projectile globally
;(require 'helm-config)
;(global-set-key (kbd "M-x") 'helm-M-x)
(projectile-global-mode t)

;; use undo-tree
(global-undo-tree-mode)

;; Local customizations

;; windows
(load-file "~/emacs.git/local/windows.el")

(setq auto-mode-alist
      (cons
       '("\\.md$" . markdown-mode)
       auto-mode-alist))

(add-hook 'markdown-mode-hook
          '(lambda ()
             (flyspell-mode)))
                                 

(setq auto-mode-alist
      (cons
       '("\\.js$" . js2-mode)
       auto-mode-alist))

;; Add a space padding to the linum gutter
(setq linum-format "%d ")

(defun editing-setup (&optional skip-fci)
  "Common editing setup"
  (linum-mode)
  (which-key-mode)
  (rainbow-mode)
  (message "skip fci? %s" skip-fci)
  (unless skip-fci (fci-mode))
  (hl-line-mode)
  (whitespace-mode))

(defun web-mode-newline-fixup ()
  "Inserts a newline and reloads web-mode"
  (interactive)
  (newline-and-indent)
  (web-mode-reload))

;; web-mode
(defun my-web-mode-hook ()
  "Hooks for web-mode."
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (editing-setup t)
  )
(add-hook 'web-mode-hook 'my-web-mode-hook)
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.css\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.json\\'" . web-mode))

;; Javascript indent to 2
(setq js2-mode-basic-offset 2)
(add-hook 'js2-mode-hook 'editing-setup)

;; Scala
(defun scala-loader ()
  "Loads all scala stuff"
  (require 'scala-mode2)
  (require 'ensime)
  ;; Ensime save hooks
  (setq ensime-source-buffer-saved-hook
        '(lambda ()
                                        ;(ensime-refactor-organize-imports)
                                        ;(ai2-organize-imports)
                                        ;(ensime-format-source)
           ))
  (add-hook 'scala-mode-hook #'yas-minor-mode)

  (add-hook 'scala-mode-hook
            '(lambda()
               (editing-setup)
               (company-mode)
               (setq
                company-dabbrev-ignore-case nil
                company-dabbrev-code-ignore-case nil
                company-dabbrev-downcase nil
                company-idle-delay 0)
               (subword-mode)
               (ensime-scala-mode-hook)
               (load-file "~/emacs.git/local/enhance-scala-mode.el")
               (ad-activate 'newline-and-indent)
               (local-set-key (kbd "C-c C-f") 'ai2-organize-imports)
               (electric-pair-mode))))

(add-hook 'comint-mode-hook
          (lambda ()
            (define-key comint-mode-map "\C-w" 'comint-kill-region)
            (define-key comint-mode-map [C-S-backspace]
              'comint-kill-whole-line)))

(scala-loader)

;; LESS CSS
(defun less-custom ()
  "less-css-mode-hook"
  (set (make-local-variable 'tab-width) 2)
  (editing-setup))
(add-hook 'less-css-mode-hook 'flymake-less-load)
(add-hook 'less-css-mode-hook '(lambda() (less-custom)))

;; eshell tab-completion
(add-hook
 'eshell-mode-hook
 (lambda ()
   (setq pcomplete-cycle-completions nil)))

;; load any local overrides
(load-file "~/emacs-local/init.el")

(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            ;; Use spaces, not tabs.
            (setq indent-tabs-mode nil)
            ;; Pretty-print eval'd expressions.
            (define-key emacs-lisp-mode-map
              "\C-x\C-e" 'pp-eval-last-sexp)
            ;; Recompile if .elc exists.
            (add-hook (make-local-variable 'after-save-hook)
                      (lambda ()
                        (byte-force-recompile default-directory)))
            (define-key emacs-lisp-mode-map
              "\r" 'reindent-then-newline-and-indent)))
(add-hook 'emacs-lisp-mode-hook 'eldoc-mode)
