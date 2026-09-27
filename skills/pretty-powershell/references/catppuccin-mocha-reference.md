# Catppuccin Mocha Reference

Detailed reference for the Pretty PowerShell skill.

## Full Color Palette (Catppuccin Mocha)

| Role | Hex |
|---|---|
| Base (background) | `#1e1e2e` |
| Mantle | `#181825` |
| Crust | `#11111b` |
| Surface0 (selection) | `#313244` |
| Surface1 | `#45475a` |
| Text (foreground) | `#cdd6f4` |
| Subtext0 | `#a6adc8` |
| Subtext1 | `#bac2de` |
| Mauve (primary) | `#cba6f7` |
| Blue | `#89b4fa` |
| Green | `#a6e3a1` |
| Yellow | `#f9e2af` |
| Red | `#f38ba8` |
| Teal | `#94e2d5` |
| Peach | `#fab387` |
| Subtext (muted) | `#7f849c` |

## Nerd Font Install Snippet (PowerShell, user-scope, no admin)

```powershell
$ErrorActionPreference = "Stop"
$url  = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip"
$zip  = "$env:TEMP\CascadiaCodeNF.zip"
$ext  = "$env:TEMP\CascadiaCodeNF"
$dest = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
Invoke-WebRequest $url -OutFile $zip -UseBasicParsing
if (Test-Path $ext) { Remove-Item $ext -Recurse -Force }
Expand-Archive $zip -DestinationPath $ext -Force
New-Item -ItemType Directory -Force -Path $dest | Out-Null
$reg = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
Get-ChildItem "$ext\*.ttf" | ForEach-Object {
    Copy-Item $_.FullName "$dest\$($_.Name)" -Force
    $base = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
    New-ItemProperty -Path $reg -Name "$base (TrueType)" -Value "$dest\$($_.Name)" -PropertyType String -Force | Out-Null
}
```

The terminal font face name is `CaskaydiaCove Nerd Font Mono` (the Mono variant is monospaced, required for terminals).

## Alternative Color Schemes

### Tokyo Night (cool blue)

```json
{
  "name": "Tokyo Night",
  "background": "#1a1b26",
  "foreground": "#c0caf5",
  "cursorColor": "#c0caf5",
  "selectionBackground": "#33467c",
  "black": "#15161e", "red": "#f7768e", "green": "#9ece6a",
  "yellow": "#e0af68", "blue": "#7aa2f7", "purple": "#bb9af7",
  "cyan": "#7dcfff", "white": "#a9b1d6",
  "brightBlack": "#414868", "brightRed": "#f7768e", "brightGreen": "#9ece6a",
  "brightYellow": "#e0af68", "brightBlue": "#7aa2f7", "brightPurple": "#bb9af7",
  "brightCyan": "#7dcfff", "brightWhite": "#c0caf5"
}
```

### Gruvbox Dark (warm brown)

```json
{
  "name": "Gruvbox Dark",
  "background": "#282828",
  "foreground": "#ebdbb2",
  "cursorColor": "#ebdbb2",
  "selectionBackground": "#504945",
  "black": "#282828", "red": "#fb4934", "green": "#b8bb26",
  "yellow": "#fabd2f", "blue": "#83a598", "purple": "#d3869b",
  "cyan": "#8ec07c", "white": "#ebdbb2",
  "brightBlack": "#928374", "brightRed": "#fb4934", "brightGreen": "#b8bb26",
  "brightYellow": "#fabd2f", "brightBlue": "#83a598", "brightPurple": "#d3869b",
  "brightCyan": "#8ec07c", "brightWhite": "#ebdbb2"
}
```

To switch, replace the scheme in Windows Terminal `settings.json` and change `colorScheme` in profile defaults. The oh-my-posh theme palette stays Catppuccin; to retune the prompt to match, edit `omp-catppuccin.json` palette values.

## Troubleshooting

### Icons show as boxes / tofu
The Nerd Font is not loaded. Fully quit Windows Terminal (right-click taskbar icon → Close window, or kill `WindowsTerminal.exe` in Task Manager) and reopen. Verify the font face name is exactly `CaskaydiaCove Nerd Font Mono` in profile defaults.

### `Set-PSReadLineOption: The predictive suggestion feature cannot be enabled`
Only occurs when the profile runs in a non-interactive / redirected context (e.g. piping output). In a real Windows Terminal pane it works. The profile wraps these lines in `try/catch` so it degrades silently.

### oh-my-posh command not found after install
winget installs register a user PATH entry that the current shell session has not picked up. Open a new Windows Terminal tab/window.

### Prompt renders blank
Verify the theme path exists at `$HOME\Documents\PowerShell\omp-catppuccin.json` and that the profile line `oh-my-posh init pwsh --config ...` ran. Run `oh-my-posh debug --config <path> --pwd $HOME` to inspect segment rendering.

## PSReadLine Keybindings

| Key | Action |
|---|---|
| `Tab` | MenuComplete (list matches) |
| `↑` / `↓` | HistorySearchBackward / Forward (by prefix) |
| `→` | Accept inline prediction (whole line) |
| `Ctrl+→` | ForwardWord (accept one word of prediction) |
