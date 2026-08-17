;;主题颜色
;; (load-theme 'leuven-dark)
(load-theme 'wombat)

;;取消topbar
(add-to-list 'default-frame-alist '(undecorated . t)) 

;;启动时全屏
(add-to-list 'default-frame-alist '(fullscreen . fullboth))

;;Automatically refresh Dired buffers when files change on disk
(add-hook 'dired-mode-hook 'auto-revert-mode)
(global-auto-revert-mode 1)

;;关闭菜单栏 滚动条
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;;buffer禁止左右布局
(setq split-width-threshold nil)

;;配置插件包源 
(require 'package)			
(setq package-archives
      '(("gnu"   . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))
(package-initialize)

;;include builtin package 
(setq package-install-upgrade-built-in t)

;;使用use-package
(require 'use-package)
(setq use-package-always-ensure t) ;;自动安装没有的包

;;inherit from shell env variables
(use-package exec-path-from-shell
  :config
  (exec-path-from-shell-initialize))

;;add xclip package to copy because wayland cant copy
(use-package xclip
  :config
  (xclip-mode 1))
(setq select-enable-clipboard t)

;;alt+上下拖动代码行
(use-package drag-stuff
  :config
  (drag-stuff-global-mode 1)
  :bind
  ("M-<up>" . drag-stuff-up)  
  ("M-<down>" . drag-stuff-down)) 

;;ace-window
(use-package ace-window
  :bind* ("M-o" . ace-window))

;;关闭自动生成备份文件
(setq make-backup-files nil) 

;;全局行号模式
(global-display-line-numbers-mode 1)

;;C-w如果没有选中区域剪切当前行
(defun kill-current-line-if-no-region ()
  (interactive)
  (if (region-active-p)
      (kill-region (region-beginning) (region-end))
    (kill-whole-line)))
(global-set-key (kbd "C-w") #'kill-current-line-if-no-region)

;;启动时自动打开 Dired 视图
(setq initial-buffer-choice "~/work")

;;font size
(set-face-attribute 'default nil :height 150)

;;global pair mode 
(electric-pair-mode 1)

;;compile buffer enable color
(add-hook 'compilation-filter-hook #'ansi-color-compilation-filter)

;;ripgrep
(use-package rg)

;;indent of ts
(setq typescript-ts-mode-indent-offset 4)

;;submode word for tuofeng name
(global-subword-mode 1)

;;git
(use-package magit)

;;see folder size
(use-package dired-du)

;;corfu auto complete
(use-package corfu
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-preselect 'prompt)		
  (global-corfu-minibuffer nil) 
  :init
  (global-corfu-mode)
  (corfu-history-mode)
  (corfu-popupinfo-mode))

;;minibuffer auto complete
(use-package vertico
  :custom
  (vertico-cycle t)             ;; 允许列表首尾循环滚动
  (vertico-resize nil)          ;; 保持窗口高度固定，避免闪烁
  :init
  (vertico-mode 1))

;;Orderless无序空格匹配
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

;;tramp PATH variable
(use-package tramp
  :ensure nil
  :config
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path))

;;显示当前文件路径
(setq-default header-line-format
              '(:eval
                (when buffer-file-name
                  (concat "  " (abbreviate-file-name buffer-file-name)))))

;;show backtrace
(setq debug-on-error t)

;;更好的传输文件
(setq dired-dwim-target t)

;;better shell in emacs
(use-package vterm)

;;always line center
(setq ;; maximum-scroll-margin 0.5
      scroll-margin 10
      ;; scroll-conservatively 101
      )

;;----------------------CODE--------------------------

;;docker compose mode
(use-package docker-compose-mode)
;;docker
(use-package dockerfile-mode)

;;ipynb
(use-package ein)

;;csv mode
(use-package csv-mode
  :mode ("\\.csv\\'" "\\.tsv\\'"))

;;pdf
(use-package pdf-tools
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :config
  (pdf-tools-install)
  (setq pdf-view-display-size 'fit-page
        pdf-annot-activate-created-annotations t)
  ;; PDF buffer 里关掉行号,否则会报错
  (add-hook 'pdf-view-mode-hook (lambda () (display-line-numbers-mode -1))))

;;rewrite some var together
(use-package iedit)

;;markdown
(use-package markdown-mode)

;;go mode
(use-package go-mode)

;;add treesit for ts tsx using M-x treesit-install-language-grammar
(add-to-list 'auto-mode-alist '("\\.[cm]?ts\\'" . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'"     . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.[cm]?js\\'" . typescript-ts-mode))

;;python mode
(use-package python
  :ensure nil)

;;html mode
(use-package sgml-mode
  :ensure nil)

;;json mode
(use-package json-mode)

;;css mode
(use-package css-mode
  :ensure nil)

;;----------------------CODE--------------------------

;;----------------------EGLOT-LEGACY--------------------------

(use-package eglot
  :hook ((tsx-ts-mode . eglot-ensure)
	 (typescript-ts-mode . eglot-ensure)))
 (add-hook 'eglot-managed-mode-hook (lambda ()
                                      (remove-hook 'flymake-diagnostic-functions 'eglot-flymake-backend)))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((markdown-mode gfm-mode) . ("marksman" "server"))))

;;using tsc replace typescript-language-server
(with-eval-after-load 'eglot (add-to-list 'eglot-server-programs
					  '(((js-mode :language-id "javascript")
					     (js-ts-mode :language-id "javascript")
					     (tsx-ts-mode :language-id "typescriptreact")
					     (typescript-ts-mode :language-id "typescript")
					     (typescript-mode :language-id "typescript"))
					     . ;; ("npx" "tsc" "--lsp" "--stdio")
					     ;; ("tailwindcss-language-server" "--stdio")
					     ("rass" "--no-stream-diagnostics" "--" "npx" "tsc" "--lsp" "-stdio" "--" "tailwindcss-language-server" "--stdio")
					     )))
(add-hook 'tsx-ts-mode-hook (lambda () (modify-syntax-entry ?- "_")))

;;----------------------EGLOT--------------------------

;; ;;add auto complete support for vscode-html-lsp
;; (use-package yasnippet
;;   :hook (mhtml-mode . yas-minor-mode)
;;   :config
;;   (yas-reload-all))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(ace-window colorful-mode company consult corfu csv-mode dired-du
		docker docker-compose-mode dockerfile-mode drag-stuff
		eglot ein eldoc-box exec-path-from-shell git go-mode
		grip-mode iedit json-mode lsp-pyright lsp-ui magit
		orderless pdf-tools poetry rg vertico vterm xclip
		yasnippet)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
