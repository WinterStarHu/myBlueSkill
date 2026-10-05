---
name: wsl-remote-dev
description: Use this skill when the user asks to "装 WSL", "安装 Ubuntu", "远程开发环境", "WSL 远程", "内网穿透开发", "Tailscale 远程", "配置 SSH 远程", "code-server 浏览器 VS Code", or wants to set up a WSL2 Ubuntu environment accessible remotely from other devices (phone/laptop/tablet) via Tailscale, with SSH and code-server, all using China-friendly mirrors. Also use when re-installing or repairing such an environment on Windows 10/11.
version: 0.1.0
---

# WSL Remote Dev (WSL2 + Ubuntu + Tailscale + SSH + code-server)

Set up a WSL2 Ubuntu environment on Windows that is reachable from any of the user's other devices (phone/laptop/tablet) via Tailscale, exposing SSH (port 22) and code-server (browser VS Code, port 8080). All downloads use China-friendly mirrors to avoid GitHub/Store timeouts.

## What This Builds

```
[phone / laptop / tablet]
        │  Tailscale tunnel (free, fixed IP, no real-name)
        ▼
[Windows host]
   └─ WSL2 (Ubuntu 24.04)
        ├─ sshd        :22    → ssh winter@<tailscale-ip>
        ├─ code-server :8080  → http://<tailscale-ip>:8080
        └─ tailscaled         WSL has its own stable Tailscale node
```

Tailscale is installed **inside WSL** (not on Windows) so WSL gets its own stable Tailscale IP, sidestepping WSL2's IP-rotation and Windows port-forwarding headaches.

## Prerequisites

- Windows 10 22H2 (Build 19045+) or Windows 11
- WSL not yet installed (or willing to reinstall)
- Admin rights for `wsl --install` (one-time, requires reboot)
- A Tailscale account (free; sign in with Google/Microsoft/GitHub/Apple)

## Installation Workflow

Execute in order. Steps marked ⚠️ need the user (admin shell / browser auth).

### 1. Enable WSL2 (admin + reboot) ⚠️

In an **admin** PowerShell:

```powershell
wsl --install --no-distribution
wsl --set-default-version 2
```

Reboot. Then verify `wsl --status` shows default version 2.

### 2. Import Ubuntu from a China mirror

Do NOT use Microsoft Store (slow/blocked in CN). Use USTC mirror rootfs + `wsl --import`.

- rootfs: `https://mirrors.ustc.edu.cn/ubuntu-cdimage/ubuntu-base/releases/24.04/release/ubuntu-base-24.04.5-base-amd64.tar.gz` (~28 MB, gzip magic `1F 8B`)
- verify with `tar -tzf` before import
- choose install location with a real drive letter (e.g. `D:\WSL\Ubuntu`); if the target drive doesn't exist yet, partition/format it first (see `references/disk-setup.md`)

```powershell
mkdir D:\WSL\Ubuntu -Force
wsl --import Ubuntu D:\WSL\Ubuntu <path-to.tar.gz> --version 2
wsl -l -v   # expect Ubuntu VERSION 2
```

### 3. Base config inside WSL (China mirrors, user, systemd)

Run as root inside WSL. Full script in `assets/wsl-init.sh`. Key points:

- **Mirror selection is critical**: Tsinghua (`mirrors.tuna.tsinghua.edu.cn`) **returns 403** for some CN networks — do not assume it works. Aliyun (`mirrors.aliyun.com/ubuntu`) is the reliable fallback. The bootstrap script uses HTTP Aliyun first to install `ca-certificates`, then switches to HTTPS.
- pip mirror: Tsinghua `pypi.tuna.tsinghua.edu.cn` (this one works).
- Create user `winter`, add to sudo, passwordless sudo.
- Write `/etc/wsl.conf` with `[boot] systemd=true` and `[user] default=winter`, then `wsl --shutdown` to activate systemd.
- Install dev tools: `build-essential git curl wget vim zsh python3 python3-pip python3-venv openssh-server sudo gnupg lsb-release iproute2 dnsutils less file unzip`.

### 4. SSH (port 22)

- Install `openssh-server`, enable `PasswordAuthentication yes`, `ListenAddress 0.0.0.0`.
- **Disable and mask `ssh.socket`** — socket activation makes systemd restart sshd every ~20s in WSL2, killing SSH sessions. This is the #1 cause of "SSH disconnects after login".
- `ssh.service` runs directly and stays resident.
- Add `ClientAliveInterval 30` to sshd_config.
- Verify from inside WSL: `sshpass -p <pw> ssh winter@127.0.0.1`.

### 5. code-server (browser VS Code, port 8080)

- Install Node.js v22 from npmmirror binary (code-server latest requires Node 22).
- `npm install -g code-server` fails because `@parcel/watcher` pulls `git+ssh://github.com/...` (GitHub blocked in CN). **Workaround**: download the code-server release tarball via a GitHub proxy like `gh-proxy.com` and install manually. Script in `assets/code-server-install.sh`.
- Config: `~/.config/code-server/config.yaml` with `bind-addr: 0.0.0.0:8080`, `auth: password`.
- systemd service `code-server@winter.service`, enabled.

### 6. Tailscale (inside WSL)

- Add Tailscale apt source (`pkgs.tailscale.com/stable/ubuntu/noble`), install `tailscale`.
- `systemctl enable --now tailscaled`.
- `tailscale up` (outputs a URL — user authorizes in browser). Note: `tailscale set --operator=winter` alone is not enough in WSL; run `tailscale up` as root.
- Verify: `tailscale status` shows the WSL node online with a `100.x.x.x` IP.

### 7. Keep WSL alive + Tailscale stable (critical)

WSL 3.x auto-powers-off the VM when idle, which drops Tailscale and breaks everything. Two fixes:

- `C:\Users\<user>\.wslconfig` with `vmIdleTimeout=999999999` (NOT `-1`, which is invalid and gets treated as default 60s).
- A **Windows Scheduled Task** that runs at logon, holding WSL open in the background: `wsl -d Ubuntu -- bash -c "while true; do sleep 300; done"`. Script to create it in `assets/create-wsl-keepalive.ps1`.

Tailscale stability:
- `tailscale up --accept-dns=false`, and **lock `/etc/resolv.conf`** with `chattr +i` to a fixed DNS (`223.5.5.5` + `8.8.8.8`). Otherwise Tailscale and WSL fight over resolv.conf → DNS death loop → node flaps offline.
- **Do NOT install a tailscale-watchdog** that restarts tailscaled — it kills `systemd-resolved` in a loop. Tailscale self-heals.

### 8. Install Claude Code + ccs (config switch)

- `npm install -g @anthropic-ai/claude-code` (npmmirror).
- `npm install -g claude-code-config-switch` (bin `ccs`). **ESM bug**: chalk 5 breaks it; fix by `cd <pkgdir> && npm install chalk@4`.
- Create per-account configs in `~/.claude-config/claude-config.<name>.json`. Switch with `ccs env <name>`.

### 9. Access from other devices ⚠️ (user action)

On the phone/laptop/tablet: install Tailscale, sign in with the **same account**. Then:
- SSH: `ssh winter@<wsl-tailscale-ip>`
- Browser VS Code: `http://<wsl-tailscale-ip>:8080`

## What Gets Installed

| Component | Value |
|---|---|
| WSL distro | Ubuntu 24.04 (imported, not Store) |
| WSL user | `winter` (passwordless sudo) |
| Tailscale IP | `100.x.x.x` (fixed, WSL's own node) |
| SSH | port 22, password auth |
| code-server | port 8080, password auth |
| systemd | enabled (failed units: kmod-static-nodes, systemd-binfmt — harmless in WSL) |
| Claude Code | `claude` CLI |
| ccs | config switcher for multiple accounts |

## Common Pitfalls (read before troubleshooting)

- **Tsinghua mirror 403**: use Aliyun for apt.
- **ca-certificates chicken-and-egg**: HTTPS mirror fails before ca-certificates installed → bootstrap with HTTP Aliyun first.
- **`@parcel/watcher` git+ssh**: blocks `npm i -g code-server` in CN → use release tarball + proxy.
- **`ssh.socket` restart loop**: mask it, run `ssh.service` directly.
- **WSL 3.x idle poweroff**: `vmIdleTimeout=999999999` + Windows scheduled task holding WSL.
- **resolv.conf fight (Tailscale vs WSL)**: `chattr +i` a fixed resolv.conf, `--accept-dns=false`.
- **tailscale-watchdog death loop**: a watchdog that restarts tailscaled kills systemd-resolved → DNS dies → watchdog fires again. Don't install one.
- **`vmIdleTimeout=-1`** is invalid; treated as default 60s. Use a large positive number.

## Additional Resources

### Reference Files
- `references/disk-setup.md` — partition/format a new drive for WSL install location if needed.
- `references/mirrors.md` — full China mirror list and which ones are reliable.

### Assets
- `assets/wsl-init.sh` — base config script (mirrors, user, systemd, dev tools).
- `assets/code-server-install.sh` — code-server install via gh-proxy.
- `assets/create-wsl-keepalive.ps1` — Windows scheduled task to hold WSL open.
- `assets/ccs-setup.sh` — Claude Code + ccs + per-account configs.

## Verification (end-to-end)

1. `wsl -l -v` shows Ubuntu v2.
2. `wsl -d Ubuntu -- whoami` → `winter`; `systemctl is-system-running` → `running`/`degraded`.
3. `wsl -d Ubuntu -- tailscale status` → WSL node `Online: true`, IP `100.x.x.x`.
4. From another device on the same Tailscale account: `ssh winter@<ip>` works; `http://<ip>:8080` shows code-server.
5. After `wsl --shutdown` + restart: sshd, code-server, tailscaled all auto-start (systemd).
