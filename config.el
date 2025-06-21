;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-


;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


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
;;
;;
;;;; Custom (user-defined) package archives that package.el uses.
;;
;; Note that Doom's `:repo` module overrides this value for its own
;; internal purposes, and you should use `package!` to specify custom
;; repos from ELPA, MELPA or other sources. This variable is only for
;; archives that you want to enable *globally*.



;; ;; --- 为 Doom Emacs 配置国内 ELPA 镜像源 ---
;; ;; 这段代码通过修改 Straight.el 的行为，使其使用国内镜像。
;; (after! package
;;   (setq package-archives '(("gnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
;;                            ("melpa" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")
;;                            ("nongnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/"))))



;; 保持主字体使用系统默认或 Emacs 默认策略
;; 如果你没有明确设置 doom-font，Emacs 会自动选择一个默认字体。
;; 如果你之前设置了 doom-font，可以将其注释掉或删除。
;; 为中文字符集指定字体
(defun my-cjk-font ()
  (dolist (charset '(kana han cjk-misc symbol bopomofo))
    ;; 推荐使用 Sarasa Mono SC 或其他你喜欢的等宽中文字体
    (set-fontset-font t charset (font-spec :family "Sarasa Mono SC"))))

;; 将此函数添加到 Emacs 启动后设置字体的钩子中
(add-hook 'after-setting-font-hook #'my-cjk-font)

;; 如果你的 Emacs 在图形界面下运行，可能需要这个条件判断
(if (display-graphic-p)
    (progn
      (dolist (charset '(kana han cjk-misc bopomofo))
        (set-fontset-font (frame-parameter nil 'font) charset (font-spec :family "Sarasa Mono SC" :size (floor (* 1.1 (frame-char-height)))))) ; 调整中文大小，使其与英文匹配
      ;; 也可以尝试其他中文字体，例如 "PingFang SC"
      ;; (set-fontset-font (frame-parameter nil 'font) 'han (font-spec :family "PingFang SC"))
      ))


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
  ;; 确保 org-agenda-files 变量是列表形式
    ;; 将~/org/添加到org-agenda-files中
  ;; 将 org-roam-directory 添加到 org-agenda-files 中
  ;; org-roam-directory 通常会在 org-roam 加载后才被定义，所以放在 after! org 里是安全的
  (add-to-list 'org-agenda-files org-roam-directory)

  ;; 确保 Org Agenda 知道要递归扫描目录
  ;; 如果您之前已经设置了其他目录，也可以这样追加
  ;; (setq org-agenda-files (append org-agenda-files (list org-roam-directory)))
  ;; 或者更简单粗暴，直接赋值
  ;; (setq org-agenda-files (list org-roam-directory "~/path/to/your/other/org-files/"))
  )


;; --- Org-roam-UI 配置 ---
(use-package! org-roam-ui
  :after org-roam ; 确保 org-roam 加载后才加载 org-roam-ui
  :config
  (setq org-roam-ui-sync-theme t  ; 使 UI 同步 Emacs 主题
        org-roam-ui-follow t      ; 在 Emacs 中切换节点时，UI 自动跟随
        org-roam-ui-update-on-save t ; 保存 Org 文件时，UI 自动更新
        org-roam-ui-open-on-start t)) ; Emacs 启动时自动打开 Org-roam-UI (可选，可能会增加启动时间)


;; 设置系统编码为utf-8
(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)
(set-buffer-file-coding-system 'utf-8-unix)
(set-clipboard-coding-system 'utf-8-unix)
(set-file-name-coding-system 'utf-8-unix)
(set-keyboard-coding-system 'utf-8-unix)
(set-next-selection-coding-system 'utf-8-unix)
(set-selection-coding-system 'utf-8-unix)
(set-terminal-coding-system 'utf-8-unix)
(setq locale-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
;; 设置consult-ripgrep搜索中文
(add-to-list 'process-coding-system-alist '("rg" utf-8 . gbk))
