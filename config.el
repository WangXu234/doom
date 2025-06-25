

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
;;
;;
;;;; Custom (user-defined) package archives that package.el uses.
;;
;; Note that Doom's `:repo` module overrides this value for its own
;; internal purposes, and you should use `package!` to specify custom
;; repos from ELPA, MELPA or other sources. This variable is only for
;; archives that you want to enable *globally*.



;; --- 设置字体为unicode模块的字体 ---
(setq doom-symbol-font (font-spec :family "JuliaMono")) ;;将分析第一个字体是否包含非拉丁字符的字形，该字体是 doom-symbol-font
(setq doom-symbol-font doom-font)  ;;如果你的 doom-font 提供了良好的 unicode 覆盖率，请使用,如果您的字体没有提供某些字形，此包将尽力寻找另一种提供的字体。
;; 如果您想要默认使用 Symbola 字体 Miscellaneous Symbols ，请使用
(after! unicode-fonts
  (push "Symbola" (cadr (assoc "Miscellaneous Symbols" unicode-fonts-block-font-mapping))))


;; --- Org Mode 和 Org-roam 配置 ---
;; 确保你的 Doom Emacs init.el 中已经启用了 org 和 org-roam 模块，例如：
;; (org +roam)
;; 如果你想要 Org-roam UI，则为：
;; (org +roam +ui)

;; 定义你的主 Org 目录。所有通用的 Org 文件都应该放在这里。
(setq org-directory (file-truename "~/org/"))

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

(after! org
  ;; 确保 org-agenda-files 是一个列表，防止类型错误
  (unless (listp org-agenda-files)
    (setq org-agenda-files nil))

  ;; 添加你的主 Org 目录 (例如 ~/org/)
  (add-to-list 'org-agenda-files org-directory)

  ;; 显式添加你的 Org-roam 目录 (例如 ~/org/roam/)
  ;; 即使它在 org-directory 之下，显式添加可以增加代码的清晰度和未来的灵活性
  (add-to-list 'org-agenda-files org-roam-directory t)
  ;; 如果你的 daily 文件夹是 org/roam/daily，并且你希望它被显式包含
  ;; 尽管父目录递归会包含它，但你也可以显式添加，以防万一或为了明确性
  (add-to-list 'org-agenda-files (expand-file-name "daily/" org-roam-directory) t)
  ;; 注意：如果 org-roam-directory 已经是 ~/org/roam/，那么上面这行会添加 ~/org/roam/daily/
  ;; ... 如果有其他需要添加到 agenda 的特定目录，也在此处添加 ...
  )


;; --- Org-roam-UI 配置 ---
(use-package! org-roam-ui
  :after org-roam ; 确保 org-roam 加载后才加载 org-roam-ui
  :config
  (setq org-roam-ui-sync-theme t  ; 使 UI 同步 Emacs 主题
        org-roam-ui-follow t      ; 在 Emacs 中切换节点时，UI 自动跟随
        org-roam-ui-update-on-save t ; 保存 Org 文件时，UI 自动更新
        org-roam-ui-open-on-start t)) ; Emacs 启动时自动打开 Org-roam-UI (可选，可能会增加启动时间)


;; 设置默认编码为 UTF-8
(set-default-coding-systems 'utf-8)
(prefer-coding-system 'gbk)
(prefer-coding-system 'utf-8)
(setq-default buffer-file-coding-system 'utf-8)
;; ---设置consult-ripgrep支持中文搜索 ---
(set-language-environment "UTF-8")
(add-to-list 'process-coding-system-alist
                        '("[rR][gG]" . (utf-8 . gbk-dos)))


;; --- 设置deft搜索扫描目录 ---
(setq deft-directory "~/org/")


;; --- 设置连续按fd等于ESC ---
(setq evil-escape-key-sequence "fd") ; 快速连按 fd 触发 Esc



;; 1. 设置 Emacs 启动时最大化窗口
;; 推荐使用 initial-frame-alist，因为它只影响第一个启动的 Emacs 窗口
(add-to-list 'initial-frame-alist '(fullscreen . maximized))

;; 如果你希望所有新创建的 frame 也最大化，可以使用 default-frame-alist
;; 但通常 initial-frame-alist 已经足够
;; (add-to-list 'default-frame-alist '(fullscreen . maximized))

;; 2. 启动时启用 big-font-mode
;; `big-font-mode` 是 Doom Emacs 内置的一个方便模式，用于临时放大字体
;; 要在启动时启用它，我们可以在 `window-setup-hook` 中添加它
(add-hook 'window-setup-hook #'doom-big-font-mode)

;; 注意：如果你想要自定义 big-font-mode 的字体大小，
;; 你可以在此之前设置 `doom-big-font` 变量。
;; 例如，如果你想将 big font 设置为 22pt 的 Fira Code：
;; (setq doom-big-font (font-spec :family "Fira Code" :size 22))
;; 确保你的系统上安装了相应的字体。




