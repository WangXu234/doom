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
;;
;;
;;;; Custom (user-defined) package archives that package.el uses.
;;
;; Note that Doom's `:repo` module overrides this value for its own
;; internal purposes, and you should use `package!` to specify custom
;; repos from ELPA, MELPA or other sources. This variable is only for
;; archives that you want to enable *globally*.
(setq package-archives '(("gnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("melpa" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")
                         ("org" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/org/")))
;;
;;
;; (Optional) 如果需要的话，可以添加 nongnu 仓库
(add-to-list 'package-archives '("nongnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/"))
;; (Optional) 如果你希望优先使用官方源，但希望在官方源不可用时 fallback 到镜像，
;; 可以将镜像放在列表的后面，或者根据网络环境动态切换。
;; 但通常直接替换为镜像会更直接有效地解决连接慢的问题。

;; --- Org-roam 配置 ---

;; 设置 Org-roam 目录
;; 重要：将 "~/org/roam/" 替换为你希望存放 Org-roam 笔记的实际路径
(setq org-roam-directory (file-truename "~/org/roam/")) ; <-- 你的路径在这里修改

;; 检查目录是否存在，如果不存在则创建它
(unless (file-directory-p org-roam-directory)
  (message "Org-roam 目录 '%s' 不存在。正在创建..." org-roam-directory)
  (make-directory org-roam-directory t)) ; 't' 表示如果父目录不存在，也一并创建

;; (可选) 启用 Org-roam v2 确认，如果你是首次设置 V2，这通常是需要的
;; (setq org-roam-v2-ack t)

;; (可选) 启用全局补全，这样在任何 Org 文件中输入 [[ 都能触发 Org-roam 补全
(setq org-roam-completion-everywhere t)

;; (可选) 自动同步数据库（推荐启用）
(org-roam-db-autosync-enable)

;; 你可能需要的其他 Org-roam 配置
;; 例如，自定义捕获模板等
;; (setq org-roam-capture-templates
;;       '(("d" "default" plain "%?"
;;          :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+TITLE: ${title}\n")
;;          :unnarrowed t)))

;; --- Org-roam-UI 配置 ---
(use-package! org-roam-ui
  :after org-roam ; 确保 org-roam 加载后才加载 org-roam-ui
  :config
  (setq org-roam-ui-sync-theme t  ; 使 UI 同步 Emacs 主题
        org-roam-ui-follow t      ; 在 Emacs 中切换节点时，UI 自动跟随
        org-roam-ui-update-on-save t ; 保存 Org 文件时，UI 自动更新
        org-roam-ui-open-on-start t)) ; Emacs 启动时自动打开 Org-roam-UI (可选，可能会增加启动时间)

;; 建议将 org-roam-ui-mode 绑定到一个快捷键，方便启用
;; 例如，SPC n r g (Node Roam Graph)
(map! :leader
      :desc "Org-roam UI open graph"
      "n r g" #'org-roam-ui-mode) ; 这会启动一个本地 Web 服务器并打开浏览器