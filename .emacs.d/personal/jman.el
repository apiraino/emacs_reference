;; Set repo, download use-package package (wtf)
; list the packages you want
(defvar package-list '(use-package ag flycheck elpy flycheck-rust racer yaml-mode py-autopep8))
; Repos
(defvar package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                           ("melpa" . "https://melpa.org/packages/")))
; activate all the packages (in particular autoloads)
(package-initialize)
; fetch the list of packages available
(unless package-archive-contents
  (package-refresh-contents))
; install the missing packages
(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

; nlinum broken as of v1.8.1
; Activate and configure nlinum
;(global-linum-mode t)
;(use-package nlinum
;  :init
;  (defvar nlinum-format "%d ")
;  (defvar nlinum-highlight-current-line t)
;  )


;; Get and config Jedi (Python IDE)
(use-package jedi
  :init
  (add-hook 'python-mode-hook 'jedi:setup)
  (setq jedi:environment-root ".")
  (setq jedi:environment-virtualenv "./virtual")
  (setq jedi:complete-on-dot t))

;; Python header on new buffers
(auto-insert-mode)  ;;; Adds hook to find-files-hook
(defvar auto-insert-directory "~/.emacs.d/personal/") ;;; Or use custom, *NOTE* Trailing slash important
(defvar auto-insert-query nil) ;;; If you don't want to be prompted before insertion
(define-auto-insert "\.py" "my-python-template.py")

;; Enable AbbrevMode
;; https://www.emacswiki.org/emacs/AbbrevMode
(setq abbrev-file-name
      "~/.emacs.d/personal/abbrev_defs")
(setq-default abbrev-mode t)

(setq tab-width 4)

; disable stupid spell checker
(defvar prelude-flyspell nil)


; Python linter (pep8) on save

; Only run flymake if I've not been typing for 5 seconds
(defvar flymake-no-changes-timeout 5)
(use-package py-autopep8
  :init
  (add-hook 'elpy-mode-hook 'py-autopep8-enable-on-save))


; Rust stuff

; run rustfmt everytime you save a buffer
(use-package rust-mode
  :mode "\\.rs\\'"
  :init
  (defvar rust-format-on-save t))


;; flycheck-rust
(use-package flycheck-rust
    :init
    (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

; Racer
(use-package racer
    :init
    (add-hook 'rust-mode-hook #'racer-mode)
    (add-hook 'racer-mode-hook #'eldoc-mode)
    (global-set-key (kbd "C-c ?") 'racer-describe)
    (global-set-key (kbd "C-c .") 'racer-find-definition)
    (global-set-key (kbd "C-c ,") 'pop-tag-mark)
)
