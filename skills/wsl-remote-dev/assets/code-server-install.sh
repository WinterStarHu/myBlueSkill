#!/bin/bash
# code-server 安装脚本（通过 gh-proxy 下载二进制，绕开 npm 的 git+ssh 依赖）
# 前置: Node.js v22 已装（code-server 最新版要求 v22）
set -e

CS_USER=${CS_USER:-winter}
CS_PASSWORD=${CS_PASSWORD:-winter2026}

echo "==== 1. 通过 gh-proxy 下载 code-server 二进制 ===="
cd /tmp
URL="https://gh-proxy.com/https://github.com/coder/code-server/releases/download/v4.106.3/code-server-4.106.3-linux-amd64.tar.gz"
curl -fsSL -A "Mozilla/5.0" -o code-server.tar.gz "$URL"
echo "下载完成: $(ls -lh code-server.tar.gz | awk '{print $5}')"

echo "==== 2. 解压到 /usr/local/lib ===="
rm -rf /usr/local/lib/code-server-4.106.3 2>/dev/null
tar -xzf code-server.tar.gz -C /usr/local/lib
CS_DIR=$(ls -d /usr/local/lib/code-server-* | head -1)
ln -sf "$CS_DIR/bin/code-server" /usr/local/bin/code-server
echo "code-server 版本: $(/usr/local/bin/code-server --version | head -1)"

echo "==== 3. 配置 ===="
mkdir -p /home/$CS_USER/.config/code-server
cat > /home/$CS_USER/.config/code-server/config.yaml <<EOF
bind-addr: 0.0.0.0:8080
auth: password
password: $CS_PASSWORD
cert: false
EOF
chown -R $CS_USER:$CS_USER /home/$CS_USER/.config

echo "==== 4. systemd 服务 ===="
cat > /etc/systemd/system/code-server@$CS_USER.service <<EOF
[Unit]
Description=code-server
After=network.target

[Service]
Type=exec
User=$CS_USER
Group=$CS_USER
WorkingDirectory=/home/$CS_USER
Environment=PATH=/usr/local/bin:/usr/bin:/bin:/home/$CS_USER/.local/bin
ExecStart=/usr/local/bin/code-server --config /home/$CS_USER/.config/code-server/config.yaml
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now code-server@$CS_USER
sleep 3
systemctl is-active code-server@$CS_USER
ss -tlnp | grep ':8080' || echo '8080 未监听（检查日志）'

echo "==== 完成 ===="
echo "访问: http://localhost:8080  密码: $CS_PASSWORD"

# Node.js v22 安装（如果没有）
if ! command -v node >/dev/null || ! node -v | grep -q 'v22'; then
  echo ""
  echo "==== 附: 安装 Node.js v22 (npmmirror) ===="
  cd /tmp
  curl -fsSL -o node.tar.gz "https://registry.npmmirror.com/-/binary/node/latest-v22.x/node-v22.9.0-linux-x64.tar.gz"
  rm -f /usr/local/bin/node /usr/local/bin/npm /usr/local/bin/npx 2>/dev/null
  rm -rf /usr/local/lib/node_modules 2>/dev/null
  tar -xzf node.tar.gz -C /usr/local --strip-components=1
  rm -f node.tar.gz
  echo "node: $(node -v)  npm: $(npm -v)"
  npm config set registry https://registry.npmmirror.com
fi
