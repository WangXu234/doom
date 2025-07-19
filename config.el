;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(setq doom-symbol-font doom-font)

;; --- Org Mode 和 Org-roam 配置 ---
;; Org-roam 笔记的存储目录，通常是你的主 org-directory 的一个子目录。
;; 确保这个目录存在。
(setq org-roam-directory (file-truename "~/org/roam/"))

;; --- 自动创建相关目录 ---
;; 如果这些目录不存在，就自动创建它们并给出提示
(unless (file-directory-p org-directory)
  (make-directory org-directory t)
  (message "Org 目录 '%s' 已创建。" org-directory))

(unless (file-directory-p org-roam-directory)
  (make-directory org-roam-directory t)
  (message "Org-roam 目录 '%s' 已创建。" org-roam-directory))

;; --- Org-agenda日历检索设置 ---

(after! org-roam
;;动态追踪agenda－files，完成的TODO自动排除
;;* dynamic agenda https://github.com/brianmcgillion/doomd/blob/master/config.org
  ;; https://d12frosted.io/posts/2021-01-16-task-management-with-roam-vol5.html
  ;; The 'roam-agenda' tag is used to tell vulpea that there is a todo item in this file
  (add-to-list 'org-tags-exclude-from-inheritance "roam-agenda")

  (require 'vulpea)

  (defun vulpea-buffer-p ()
    "Return non-nil if the currently visited buffer is a note."
    (and buffer-file-name
         (string-prefix-p
          (expand-file-name (file-name-as-directory org-roam-directory))
          (file-name-directory buffer-file-name))))

  (defun vulpea-project-p ()
    "Return non-nil if current buffer has any todo entry.

TODO entries marked as done are ignored, meaning the this
function returns nil if current buffer contains only completed
tasks."
    (seq-find                                 ; (3)
     (lambda (type)
       (eq type 'todo))
     (org-element-map                         ; (2)
         (org-element-parse-buffer 'headline) ; (1)
         'headline
       (lambda (h)
         (org-element-property :todo-type h)))))

  (defun vulpea-project-update-tag (&optional arg)
    "Update PROJECT tag in the current buffer."
    (interactive "P")
    (when (and (not (active-minibuffer-window))
               (vulpea-buffer-p))
      (save-excursion
        (goto-char (point-min))
        (let* ((tags (vulpea-buffer-tags-get))
               (original-tags tags))
          (if (vulpea-project-p)
              (setq tags (cons "roam-agenda" tags))
            (setq tags (remove "roam-agenda" tags)))

          ;; cleanup duplicates
          (setq tags (seq-uniq tags))

          ;; update tags if changed
          (when (or (seq-difference tags original-tags)
                    (seq-difference original-tags tags))
            (apply #'vulpea-buffer-tags-set tags))))))

  ;; https://systemcrafters.net/build-a-second-brain-in-emacs/5-org-roam-hacks/
  (defun my/org-roam-filter-by-tag (tag-name)
    (lambda (node)
      (member tag-name (org-roam-node-tags node))))

  (defun my/org-roam-list-notes-by-tag (tag-name)
    (mapcar #'org-roam-node-file
            (seq-filter
             (my/org-roam-filter-by-tag tag-name)
             (org-roam-node-list))))

  (defun dynamic-agenda-files-advice (orig-val)
    (let ((roam-agenda-files (delete-dups (my/org-roam-list-notes-by-tag "roam-agenda"))))
      (cl-union orig-val roam-agenda-files :test #'equal)))

  (add-hook 'before-save-hook #'vulpea-project-update-tag)
  (advice-add 'org-agenda-files :filter-return #'dynamic-agenda-files-advice)
  )

;; 设置org高级搜索
(use-package! org-ql
  ;; Set the directories where org-ql will search
  :custom
  (org-ql-search-dirs '("~/org")) ; <-- This is the key change
  ;; Optionally, bind a key for quick access
  :bind
  ("C-c o q" . org-ql-search))

(use-package! websocket
  :after org-roam)

;; --- Org-roam-UI 配置 ---
(use-package! org-roam-ui
  :after org-roam ; 确保 org-roam 加载后才加载 org-roam-ui
  :config
  (setq org-roam-ui-sync-theme t  ; 使 UI 同步 Emacs 主题
        org-roam-ui-follow t      ; 在 Emacs 中切换节点时，UI 自动跟随
        org-roam-ui-update-on-save t ; 保存 Org 文件时，UI 自动更新
        org-roam-ui-open-on-start t)) ; Emacs 启动时自动打开 Org-roam-UI (可选，可能会增加启动时间)


;; ---设置consult-ripgrep支持中文搜索，警告：仅在Windows下使用这些代码，linux不要乱用 ---
(set-language-environment "UTF-8")
;; (prefer-coding-system 'gbk)
(add-to-list 'process-coding-system-alist
             '("[rR][gG]" . (utf-8 . gbk-dos)))
(setq-default buffer-file-coding-system 'utf-8-unix)
(set-charset-priority 'unicode)
(prefer-coding-system 'utf-8)
(setq system-time-locale "C")



;;--- 解决find note出现文件名乱码的问题 ---
(defun projectile-files-via-ext-command@decode-utf-8 (root command)
  "Advice override `projectile-files-via-ext-command' to decode shell output."
  (when (stringp command)
    (let ((default-directory root))
      (with-temp-buffer
        (shell-command command t "*projectile-files-errors*")
        (decode-coding-region (point-min) (point-max) 'utf-8) ;; ++
        (let ((shell-output (buffer-substring (point-min) (point-max))))
          (split-string (string-trim shell-output) "\0" t))))))

(advice-add 'projectile-files-via-ext-command
            :override 'projectile-files-via-ext-command@decode-utf-8)

;; 设置deft搜索你的笔记目录为 ~/org
(setq deft-directory "~/org/")

;; 确保 Deft 也会递归搜索子目录
;; 这是 Deft 的默认行为，但明确设置一下也无妨
(setq deft-recursive t)

;; 设置 Deft 扫描的文件类型
;; 如果你的 Org 笔记通常是 .org 扩展名，请确保包含它
(setq deft-extensions '("txt" "md" "org"))

;; 可选：如果你希望 Deft 不仅搜索文件名，还搜索文件内容摘要
;; 并且你的 Org 文件包含 Org-mode 语法，可以启用解析
(setq deft-parse-org t)

;; --- 设置连续按fd等于ESC ---
(setq evil-escape-key-sequence "fd") ; 快速连按 fd 触发 Esc


;; 1. 设置 Emacs 启动时最大化窗口
;; 推荐使用 initial-frame-alist，因为它只影响第一个启动的 Emacs 窗口
(add-to-list 'initial-frame-alist '(fullscreen . maximized))

;; 如果你希望所有新创建的 frame 也最大化，可以使用 default-frame-alist
;; 但通常 initial-frame-alist 已经足够
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;;;; 2. 启动时启用 big-font-mode
;; `big-font-mode` 是 Doom Emacs 内置的一个方便模式，用于临时放大字体
;; 要在启动时启用它，我们可以在 `window-setup-hook` 中添加它
(add-hook 'window-setup-hook #'doom-big-font-mode)

;; 注意：如果你想要自定义 big-font-mode 的字体大小，
;; 你可以在此之前设置 `doom-big-font` 变量。
;; 例如，如果你想将 big font 设置为 22pt 的 Fira Code：
;;(setq doom-big-font (font-spec :family "Fira Code" :size 22))
;; 确保你的系统上安装了相应的字体。


;; org-srs configuration
(use-package! fsrs
  :defer t) ; Defer loading until needed

(use-package! org-srs
  :after org ; Ensure org-srs loads after org-mode is available
  :hook (org-mode . org-srs-embed-overlay-mode)
  :config
  (map! :map org-mode-map
        :localleader
        "j a" #'org-srs-review-rate-again ; j for Again (最难)
        "j h" #'org-srs-review-rate-hard  ; k for Hard
        "j g" #'org-srs-review-rate-good  ; l for Good
        "j e" #'org-srs-review-rate-easy)  ; ; for Easy (最易)
  )


;; --- 配置pyim输入法 ---
(require 'pyim)
(require 'pyim-greatdict)
(require 'pyim-cregexp-utils)
(require 'pyim-cstring-utils)

(setq default-input-method "pyim")
(pyim-default-scheme 'microsoft-shuangpin)
(pyim-basedict-enable)
(pyim-greatdict-enable)
(setq pyim-cloudim 'baidu)
(setq pyim-cloudim 'google)
(require 'pyim-dregcache)
(setq pyim-dcache-backend 'pyim-dregcache)
;;Emacs 启动时加载 pyim 词库
(add-hook 'emacs-startup-hook
          (lambda () (pyim-restart-1 t)))


;; 输入法内切换中英文输入
(global-set-key (kbd "C-c i") 'pyim-toggle-input-ascii)

;;use posframe
(require 'posframe)
(setq pyim-page-tooltip 'posframe)

;;取消模糊音
(setq pyim-pinyin-fuzzy-alist nil)

;; 开启代码搜索中文功能（比如拼音，五笔码等）
(pyim-isearch-mode 1)

;;让 vertico, selectrum 等补全框架，通过 orderless 支持拼音搜索候选项功能
(defun my-orderless-regexp (orig-func component)
  (let ((result (funcall orig-func component)))
    (pyim-cregexp-build result)))

(advice-add 'orderless-regexp :around #'my-orderless-regexp)

;;使用其它字符翻页
(define-key pyim-mode-map "." 'pyim-page-next-page)
(define-key pyim-mode-map "," 'pyim-page-previous-page)


;;---解决minibuffer中pyim输入显式的问题---
;; 定义一个建议函数，用于修改 pyim-page-info-format 的行为
(defun my-pyim-page-info-format-minibuffer-advice (original-function style page-info)
  ;; 如果当前样式是 minibuffer (Minibuffer显示模式)
  (if (eq style 'minibuffer)
      ;; 使用自定义的格式字符串：拼音在第一行，候选词在第二行
      (format "%s%s:\n%s(%s/%s)" ; 注意这里的 \n (换行符)
              ;; 生成拼音预览字符串
              (pyim-page-preview-create
               (plist-get page-info :scheme))
              ;; 辅助输入法提示 (如果有)
              (if (plist-get page-info :assistant-enable) " (辅)" "")
              ;; 生成候选词列表字符串
              (pyim-page-menu-create
               (plist-get page-info :candidates)
               (plist-get page-info :position)
               nil ; 没有行分隔符
               (plist-get page-info :hightlight-current))
              ;; 当前页码
              (plist-get page-info :current-page)
              ;; 总页数
              (plist-get page-info :total-page))
    ;; 如果是其他显示样式，则调用原始的 pyim-page-info-format 函数
    (funcall original-function style page-info)))

;; 将我们的建议函数添加到 pyim-page-info-format 函数上
(advice-add 'pyim-page-info-format :around #'my-pyim-page-info-format-minibuffer-advice)

;; 可选：如果两行显示后 Minibuffer 高度不够，可以尝试增加 Minibuffer 的最大高度
;; (setq max-mini-window-height 5) ; 根据需要调整此值


