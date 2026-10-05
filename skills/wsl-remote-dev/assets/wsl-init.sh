#!/bin/bash
# WSL2 Ubuntu 初始化配置脚本（阿里云源，解决 ca-certificates 鸡蛋问题）
# 用法: wsl -d Ubuntu -u root -- bash wsl-init.sh
set -e

echo "==== 1a. 临时用阿里云 HTTP 源 + 允许未签名 ===="
cat > /etc/apt/sources.list <<'EOF'
deb [allow-insecure=yes] http://mirrors.aliyun.com/ubuntu/ noble main restricted universe multiverse
deb [allow-insecure=yes] http://mirrors.aliyun.com/ubuntu/ noble-updates main restricted universe multiverse
deb [allow-insecure=yes] http://mirrors.aliyun.com/ubuntu/ noble-security main restricted universe multiverse
EOF
if [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then
  mv /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources.bak 2>/dev/null || true
fi
mkdir -p /etc/apt/apt.conf.d
cat > /etc/apt/apt.conf.d/99insecure <<'EOF'
Acquire::AllowInsecureRepositories "true";
Acquire::AllowDowngradeToInsecureRepositories "true";
EOF

echo "==== 1b. apt update (HTTP) ===="
apt-get update || true

echo "==== 1c. 先装 ca-certificates ===="
DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-unauthenticated ca-certificates || true
/usr/sbin/update-ca-certificates 2>/dev/null || true

echo "==== 1d. 换回 HTTPS 阿里云源 ===="
cat > /etc/apt/sources.list <<'EOF'
deb https://mirrors.aliyun.com/ubuntu/ noble main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ noble-updates main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ noble-backports main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ noble-security main restricted universe multiverse
EOF
rm -f /etc/apt/apt.conf.d/99insecure

echo "==== 2. apt update / upgrade ===="
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

echo "==== 3. 安装基础开发工具 ===="
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  build-essential curl wget git vim zsh ca-certificates \
  python3 python3-pip python3-venv \
  openssh-server sudo gnupg lsb-release iproute2 dnsutils \
  less file unzip iputils-ping

echo "==== 4. pip 换清华源 ===="
cat > /etc/pip.conf <<'EOF'
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
EOF

echo "==== 5. 创建用户 winter ===="
USER=${WINTER_USER:-winter}
if ! id -u "$USER" >/dev/null 2>&1; then
  useradd -m -s /bin/bash "$USER"
  echo "${USER}:${WINTER_PASS:-123456}" | chpasswd
  usermod -aG sudo "$USER"
fi
mkdir -p /etc/sudoers.d
echo "$USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER
chmod 440 /etc/sudoers.d/$USER
echo "用户 $USER 已创建"

echo "==== 6. 配置 wsl.conf ===="
cat > /etc/wsl.conf <<'EOF'
[user]
default=winter

[boot]
systemd=true

[network]
generateResolvConf=false
EOF

echo "==== 初始化完成 ===="
echo "下一步: wsl --shutdown, 然后重新进入"
