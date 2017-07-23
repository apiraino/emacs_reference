;; Set repo, download use-package package (wtf)
; list the packages you want
(setq package-list '(use-package))
; Repos
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
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

;; Get and config Jedi (Python IDE)
(use-package jedi
        :ensure t
        :init
        (add-hook 'python-mode-hook 'jedi:setup)
        (setq jedi:environment-root ".")
        (setq jedi:environment-virtualenv "./virtual")
        (setq jedi:complete-on-dot t))

;; Python header on new buffers
 (auto-insert-mode)  ;;; Adds hook to find-files-hook
    (setq auto-insert-directory "~/.emacs.d/personal/") ;;; Or use custom, *NOTE* Trailing slash important
    (setq auto-insert-query nil) ;;; If you don't want to be prompted before insertion
    (define-auto-insert "\.py" "my-python-template.py")

;; Enable AbbrevMode
;; https://www.emacswiki.org/emacs/AbbrevMode
(setq abbrev-file-name
      "~/.emacs.d/personal/abbrev_defs")
(setq-default abbrev-mode t)

(setq default-tab-width 4)

; disable stupid spell checker
(setq prelude-flyspell nil)

; run rustfmt everytime you save a buffer
(setq rust-format-on-save t)
