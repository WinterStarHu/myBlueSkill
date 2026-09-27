# Pretty PowerShell

Windows PowerShell / Windows Terminal 的护眼美化方案。

## 包含

- PowerShell 7 + CaskaydiaCove Nerd Font Mono 字体
- Catppuccin Mocha 柔和暖色暗系配色（背景 `#1e1e2e`，低饱和不刺眼）
- oh-my-posh 自定义主题（OS 图标 / 路径 / Git / 执行耗时 / `❯`）
- PSReadLine 语法高亮 + 历史预测 + 菜单补全
- 实用别名（`ll` `..` `which` `touch` `mkcd` `g` `gs` `gl`）

## 安装

实际配置文件和安装步骤在 `skills/pretty-powershell/` 这个 Claude Code skill 里：

- `skills/pretty-powershell/SKILL.md` —— 安装流程
- `skills/pretty-powershell/assets/` —— 三个配置文件（主题 / profile / Windows Terminal 配色）
- `skills/pretty-powershell/references/` —— 详细配色、字体安装脚本、备选配色方案

直接让 Claude 触发该 skill（说「美化 powershell」），或按 `SKILL.md` 手动执行。
