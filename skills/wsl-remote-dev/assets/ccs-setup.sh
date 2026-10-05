#!/bin/bash
# Claude Code + ccs 安装与多账号配置脚本
# 前置: Node.js v22 已装（走 npmmirror 淘宝源）
set -e

CCS_USER=${CCS_USER:-winter}

echo "==== 1. 安装 Claude Code ===="
npm install -g @anthropic-ai/claude-code --registry=https://registry.npmmirror.com
echo "claude 版本: $(claude --version 2>&1 | head -1)"

echo ""
echo "==== 2. 安装 ccs (claude-code-config-switch) ===="
npm install -g claude-code-config-switch --registry=https://registry.npmmirror.com

echo "==== 2b. 修复 ccs 的 chalk ESM bug (降级到 chalk@4) ===="
cd /usr/local/lib/node_modules/claude-code-config-switch
npm install chalk@4 --registry=https://registry.npmmirror.com
echo "ccs --version: $(ccs --version 2>&1 | head -1)"

echo ""
echo "==== 3. 创建多账号配置 ===="
# 配置存储在 ~/.claude-config/claude-config.<名字>.json
# 切换时 ccs 把对应内容写入 ~/.claude/settings.json
CONFIG_DIR=/home/$CCS_USER/.claude-config
mkdir -p "$CONFIG_DIR"
chown -R $CCS_USER:$CCS_USER "$CONFIG_DIR"

# 修改下面的 URL/TOKEN 为你自己的账号
# 格式: create_config <名字> <base_url> <token> <描述>
create_config() {
  local name="$1" base_url="$2" token="$3" desc="$4"
  cat > "$CONFIG_DIR/claude-config.$name.json" <<EOF
{
  "env": {
    "ANTHROPIC_BASE_URL": "$base_url",
    "ANTHROPIC_AUTH_TOKEN": "$token",
    "ANTHROPIC_MODEL": "claude-sonnet-4-5-20250929",
    "API_TIMEOUT_MS": "600000"
  },
  "description": "$desc"
}
EOF
  chown $CCS_USER:$CCS_USER "$CONFIG_DIR/claude-config.$name.json"
  echo "  已创建: $name ($desc)"
}

# 示例：火山网关 + 阿里 dashscope（替换为你的真实账号）
VOLCANO_URL="https://<your-volcano-gateway>.apigateway-cn-beijing.volceapi.com/compatible"
DASHSCOPE_URL="https://dashscope.aliyuncs.com/apps/anthropic"

create_config "ws"  "$VOLCANO_URL"   "<token-ws>"  "火山网关-伟斯"
create_config "sf"  "$VOLCANO_URL"   "<token-sf>"  "火山网关-善飞"
create_config "hdx" "$VOLCANO_URL"   "<token-hdx>" "火山网关-冬星"
create_config "zj"  "$VOLCANO_URL"   "<token-zj>"  "火山网关-赵京"
create_config "xh"  "$DASHSCOPE_URL" "<token-xh>"  "阿里dashscope-晓华"

echo ""
echo "==== 4. 切到默认配置 ws ===="
sudo -u $CCS_USER ccs env ws 2>&1 | head -3

echo ""
echo "==== 完成 ===="
echo "切换账号: ccs env <名字>"
echo "  ws / sf / hdx / zj  火山网关各账号"
echo "  xh                  阿里dashscope"
echo "列出: ccs env"
