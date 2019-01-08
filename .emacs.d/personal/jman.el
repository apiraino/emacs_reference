;; Set repo, download use-package package (wtf)
; list the packages you want
; and failed to be automatically installed
; n.b. jedi needed by prelude
; n.b. rust-mode depends on racer (no need to explicit the dependency)
(defvar package-list '(use-package ag jedi elpy flycheck flycheck-rust ox-wk racer yaml-mode py-autopep8 git-gutter org-journal xclip rcirc-notify))
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

; enable xclip mode (copy directly to Linux clipboard)
(xclip-mode 1)

; Enable Mediawiki exporter
; https://github.com/w-vi/ox-wk.el/
(require 'ox-wk)

;;;; IRC settings

;; default join these channels when connecting this server
(setq rcirc-server-alist
      '(("irc.freenode.net"
         :channels ("#rust-beginners" "#link_cleaner"))
        )
      )
(add-to-list 'rcirc-server-alist
             '("irc.mozilla.org"
               :channels ("#rocket"))
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
This doesn't support the chanserv auth method"
  (unless arg
    (dolist (p (auth-source-search :port '("nickserv" "bitlbee" "quakenet")
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
(eval-after-load 'rcirc '(require 'rcirc-notify))
(eval-after-load 'rcirc '(rcirc-notify-add-hooks))

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
             "### <a id=\"part_i\"></a>Title I: \n"
             "### <a id=\"part_ii\"></a>Title II: \n"
             "### <a id=\"part_iii\"></a>Title 3: \n\n"
             ))))
(global-set-key (kbd "C-x c") 'create_blog_stub)
