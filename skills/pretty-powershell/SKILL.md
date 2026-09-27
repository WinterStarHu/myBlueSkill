---
name: pretty-powershell
description: This skill should be used when the user asks to "美化 PowerShell", "美化 powershell", "pretty powershell", "set up oh-my-posh", "Catppuccin terminal theme", "Windows Terminal theme", "护眼终端配色", "custom prompt", or wants to improve the PowerShell prompt, colors, font, tab-completion, or history prediction on Windows. Installs PowerShell 7, a Nerd Font, oh-my-posh with a Catppuccin Mocha theme, and PSReadLine enhancements, all user-scope without admin rights.
version: 0.1.0
---

# Pretty PowerShell (Catppuccin Mocha)

Beautify the Windows PowerShell / Windows Terminal experience with an eye-friendly dark color scheme, a Nerd Font, an oh-my-posh prompt, and PSReadLine enhancements. All installs are user-scope; no elevation required.

## Prerequisites

- Windows 10/11 with Windows Terminal installed
- winget available (default on Windows 11)
- No admin rights required

## Installation Workflow

Execute the steps in order.

### 1. Install PowerShell 7

```
winget install --id Microsoft.PowerShell -e --accept-source-agreements --accept-package-agreements --disable-interactivity
```

### 2. Install oh-my-posh

```
winget install --id JanDeDobbeleer.OhMyPosh -e --accept-source-agreements --accept-package-agreements --disable-interactivity
```

### 3. Install CaskaydiaCove Nerd Font

Download and install the Nerd Font (Cascadia Code variant) to the user fonts directory so oh-my-posh icons render. The full PowerShell install snippet that copies TTFs to `%LOCALAPPDATA%\Microsoft\Windows\Fonts` and registers them under `HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts` is in `references/catppuccin-mocha-reference.md`.

### 4. Deploy the oh-my-posh theme

Copy `assets/omp-catppuccin.json` to `$HOME\Documents\PowerShell\omp-catppuccin.json`.

### 5. Deploy the PowerShell 7 profile

Copy `assets/Microsoft.PowerShell_profile.ps1` to `$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`. If a profile already exists, preserve existing managed blocks (for example OpenSpec completion) and append the configuration section rather than overwriting.

### 6. Configure Windows Terminal

Merge the color scheme and profile defaults from `assets/windows-terminal-catppuccin-mocha.json` into the Windows Terminal `settings.json` (at `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`). Set the default profile to PowerShell 7 and the default font face to `CaskaydiaCove Nerd Font Mono`.

### 7. Restart Windows Terminal

Fully close all Windows Terminal windows and reopen so the new font and color scheme take effect.

## What Gets Installed

| Component | Value |
|---|---|
| Shell | PowerShell 7 |
| Font | CaskaydiaCove Nerd Font Mono |
| Color scheme | Catppuccin Mocha (background `#1e1e2e`) |
| Prompt | oh-my-posh with custom Catppuccin theme |
| PSReadLine | Syntax highlighting, history prediction (ListView), MenuComplete, prefix history search |
| Aliases | `ll` `..` `...` `which` `touch` `mkcd` `g` `gs` `gl` |

## Customization

- **Color scheme variants**: Tokyo Night and Gruvbox Dark palettes are in `references/catppuccin-mocha-reference.md`.
- **Prompt segments**: Edit `omp-catppuccin.json` to add or remove segments (time, battery, node version).
- **Font size / padding**: Adjust in the Windows Terminal profile defaults.

## Usage Tips

- **Tab**: menu-style completion (list matches, arrow to select)
- **↑ / ↓**: search history by typed prefix
- **Gray prediction**: accept whole line with →, accept one word with Ctrl+→

## Additional Resources

### Reference Files
- **`references/catppuccin-mocha-reference.md`** — Full color palette, Nerd Font install snippet, alternative color schemes, troubleshooting.

### Assets
- **`assets/omp-catppuccin.json`** — oh-my-posh theme config.
- **`assets/Microsoft.PowerShell_profile.ps1`** — PowerShell 7 profile.
- **`assets/windows-terminal-catppuccin-mocha.json`** — Windows Terminal color scheme + profile defaults.
