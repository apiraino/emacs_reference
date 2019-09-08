;; Set repo, download use-package package (wtf)
; list the packages you want
; and failed to be automatically installed
; - jedi needed by prelude
; - rust-mode depends on racer (no need to explicit the dependency)
; - flycheck-rust already configured by prelude-rust.el module
(defvar package-list '(use-package rg jedi flycheck ox-wk racer yaml-mode py-autopep8 git-gutter org-journal xclip web-mode))
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

; configure git-gutter
(global-git-gutter-mode t)

; nlinum broken as of v1.8.1
; Activate and configure nlinum
;(global-linum-mode t)
;(use-package nlinum
;  :init
;  (defvar nlinum-format "%d ")
;  (defvar nlinum-highlight-current-line t)
;  )

;; Workaround ELPA SSL bug (fixed in 26.3)
;; src: https://irreal.org/blog/?p=8243
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")

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
(define-auto-insert "\.py" "~/.emacs.d/personal/my-python-template.py")

;; Enable AbbrevMode
;; https://www.emacswiki.org/emacs/AbbrevMode
(setq abbrev-file-name
      "~/.emacs.d/personal/abbrev_defs")
(setq-default abbrev-mode t)

(setq tab-width 4)

; Set default colum width (set-fill-column, C-x f) when formatting line length (M-q)
(setq-default fill-column 80)

; disable spell checker
(setq prelude-flyspell nil)

; Python linter (pep8) on save

; Only run flymake if I've not been typing for 5 seconds
(defvar flymake-no-changes-timeout 5)
(use-package py-autopep8
  :init
  (add-hook 'elpy-mode-hook 'py-autopep8-enable-on-save))

; Rust stuff

;; flycheck-rust
;; (use-package flycheck-rust
;;    :init
;;    (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

; Racer
(use-package racer
    :init
    (add-hook 'rust-mode-hook #'racer-mode)
    (add-hook 'racer-mode-hook #'eldoc-mode)
    (global-set-key (kbd "C-c ?") 'racer-describe)
    (global-set-key (kbd "C-c .") 'racer-find-definition)
    (global-set-key (kbd "C-c ,") 'pop-tag-mark)
)

; enable xclip mode (copy directly to Linux clipboard)
(xclip-mode 1)

; Enable Mediawiki exporter
; https://github.com/w-vi/ox-wk.el/
(require 'ox-wk)

; Enable org journal mode
(require 'org-journal)

;;;; IRC settings

;; default join these channels when connecting this server
;; (setq rcirc-server-alist
;;       '(("irc.freenode.net"
;;          :nick "<nick>"
;;          :password "<pwd>"
;;          :channels ("#test-mynick"))))

(setq rcirc-server-alist
      '(("irc.freenode.net"
         :nick "apiraino"
         :channels ("#rust-beginners"))
        )
      )

(add-to-list 'rcirc-server-alist
             '("chat.freenode.net"
               :nick "apiraino"
               :channels ("#rocket"))
             )
(add-to-list 'rcirc-server-alist
             '("irc.gimp.org"
               :nick "apiraino"
               :channels ("#rust"))
             )

;; TODO: znc server
;; (setq rcirc-server-alist
;;       '(("znc-server"
;;          :nick "znc-username"
;;          :password "znc-username:znc-password"
;;          :full-name "full-name")))

;; set encrypted auth file
;; override default "~/.authinfo.gpg"
(setq auth-sources
      '((:source "~/.secrets/rcirc-authinfo.gpg"
                 auth-source-debug t)))

;;; https://www.emacswiki.org/emacs/rcircAutoAuthentication
(defadvice rcirc (before rcirc-read-from-authinfo activate)
  "Allow rcirc to read authinfo from ~/.authinfo.gpg file via the auth-source API.
This doesn't support the chanserv and bitlbee auth method"
  (unless arg
    (dolist (p (auth-source-search :port '("nickserv" "quakenet")
                                   :require '(:port :user :secret)))
      (let ((secret (plist-get p :secret))
            (method (intern (plist-get p :port))))
        (add-to-list 'rcirc-authinfo
                     (list (plist-get p :host)
                           method
                           (plist-get p :user)
                           (if (functionp secret)
                               (funcall secret)
                             secret)))))))

;;; Libnotify notifications for rcirc
;; (eval-after-load 'rcirc '(require 'rcirc-notify))
;; (eval-after-load 'rcirc '(rcirc-notify-add-hooks))

;;; Activate Auto Fill Mode
;;; (Org mode doesn't line wrap automatically)
;;; (add-hook 'text-mode-hook 'turn-on-auto-fill)
;;; wrap at 80 columns
;;; (setq-default fill-column 80)

;;; Template for blog publishing
(defun create_blog_stub ()
  "Create a blog post stub"
  (interactive)
  (let ((post-title (read-from-minibuffer "Insert post title: ")))
    (insert (concat
             "---\n"
             "layout: post\n"
             (format "title: %s\n" post-title)
             "---\n\n"
             "### <a id=\"part_1\" href=\"#part_1\" class=\"header-anchor\">#</a> Title 1: \n"
             "### <a id=\"part_2\" href=\"#part_2\" class=\"header-anchor\">#</a> Title 2: \n"
             "### <a id=\"part_3\" href=\"#part_3\" class=\"header-anchor\">#</a> Title 3: \n\n"
             ))))
(global-set-key (kbd "C-x c") 'create_blog_stub)

;; https://github.com/bbatsov/prelude/blob/master/doc/troubleshooting.md
;; disable the arrow key navigation completely
;; (setq guru-warn-only nil)

;; Customize web-mode (mainly for Vue.js templates)
(defun my-web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-block-padding 0)
  (setq web-mode-script-padding 0)
  (setq web-mode-style-padding 0)
  (setq web-mode-block-padding 0)
)
(add-hook 'web-mode-hook  'my-web-mode-hook)
