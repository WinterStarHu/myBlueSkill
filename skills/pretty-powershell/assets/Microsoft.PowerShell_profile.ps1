# ====================================================================
# PowerShell 7 profile - 护眼 / 好看 / 易用 (Catppuccin Mocha)
# --------------------------------------------------------------------
# 若已有 profile，请保留已有 managed block（如 OpenSpec completion）
# 并将本文件的配置段追加到其后，而非整体覆盖。
# ====================================================================

# --- oh-my-posh 提示符主题 ---
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config "$HOME\Documents\PowerShell\omp-catppuccin.json" | Invoke-Expression
}

# --- PSReadLine: 语法高亮 + 历史预测 + 智能补全 ---
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -HistoryNoDuplicates
    Set-PSReadLineOption -BellStyle None
    try {
        Set-PSReadLineOption -PredictionSource History
        Set-PSReadLineOption -PredictionViewStyle ListView
    } catch {
        # 非交互/重定向环境不支持预测，静默跳过
    }
    # 语法高亮配色 (Catppuccin Mocha 调色)
    Set-PSReadLineOption -Colors @{
        Command            = '#89b4fa'
        Parameter         = '#f9e2af'
        String            = '#a6e3a1'
        Comment           = '#7f849c'
        Keyword           = '#cba6f7'
        Number            = '#fab387'
        Operator          = '#94e2d5'
        Variable          = '#cdd6f4'
        Member            = '#94e2d5'
        Emphasis          = '#cba6f7'
        Error             = '#f38ba8'
        Selection         = "`e[48;2;49;50;68m"
        InlinePrediction  = "`e[38;5;240m"
        ListPrediction    = '#7f849c'
    }
    # 键位: Tab 菜单补全, 上下箭头按前缀搜历史
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord
}

# --- 实用别名 / 函数 ---
function ll { Get-ChildItem -Force @args }
function la { Get-ChildItem -Force @args }
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function which ($name) { (Get-Command $name -ErrorAction SilentlyContinue).Source }
function touch ($file) { New-Item -ItemType File -Path $file -Force | Out-Null }
function mkcd ($dir) { New-Item -ItemType Directory -Path $dir -Force | Set-Location }
function g { git @args }
function gs { git status @args }
function gl { git log --oneline --graph --decorate @args }

# --- 终端窗口标题 ---
$Host.UI.RawUI.WindowTitle = "PowerShell"
