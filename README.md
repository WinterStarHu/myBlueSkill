# myBlueSkill

个人工作技能仓库 —— 把可复用的工作配置、美化方案、Claude Code skill 分类归档。

## 结构

```
myBlueSkill/
├── pretty/                 # 美化分类
│   └── powershell/         # PowerShell / 终端美化
└── skills/                 # Claude Code skill
    └── pretty-powershell/  # PowerShell 美化 skill（可被 Claude 加载）
```

## 分类

| 分类 | 内容 |
|---|---|
| `pretty/powershell` | Windows Terminal + PowerShell 7 + oh-my-posh + Catppuccin Mocha 护眼配色 |

## 作为 Skill 使用

`skills/pretty-powershell/` 是一个标准的 Claude Code skill。安装方式：

1. 复制 `skills/pretty-powershell/` 到 `~/.claude/skills/`（或插件的 `skills/` 目录）。
2. 对 Claude 说「美化 powershell」「pretty powershell」「oh-my-posh setup」即可触发。

或在当前仓库用 `cc --plugin-dir .` 测试（需补 `.claude-plugin/plugin.json`）。
