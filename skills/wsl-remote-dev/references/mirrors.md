# China Mirrors Reference

Which mirrors work and which don't, as of 2026-10. Test before assuming.

## Reliable (use these)

| Resource | Mirror | Notes |
|---|---|---|
| Ubuntu rootfs | `mirrors.ustc.edu.cn/ubuntu-cdimage/ubuntu-base/releases/24.04/release/` | ~28 MB; verify gzip magic `1F 8B` |
| apt packages | `mirrors.aliyun.com/ubuntu` (noble) | HTTP works for ca-certificates bootstrap; HTTPS after |
| pip packages | `pypi.tuna.tsinghua.edu.cn` | works |
| Node.js binary | `registry.npmmirror.com/-/binary/node/latest-v22.x/` | get filename from JSON listing |
| npm packages | `registry.npmmirror.com` | `npm config set registry` |
| Tailscale apt | `pkgs.tailscale.com/stable/ubuntu/noble` | directly accessible in CN |
| GitHub release proxy | `gh-proxy.com` | for code-server release tarball; test with HEAD first |

## Blocked / unreliable

| Resource | Mirror | Symptom |
|---|---|---|
| apt (Tsinghua) | `mirrors.tuna.tsinghua.edu.cn/ubuntu` | **403 Forbidden** for some CN networks — don't use |
| Ubuntu rootfs (Tsinghua) | `mirrors.tuna.tsinghua.edu.cn/ubuntu-cdimage` | 403 |
| BFSU github-release | `mirrors.bfsu.edu.cn/github-release` | 403 |
| `ghproxy.com` | — | often timeout; use `gh-proxy.com` instead |
| `npmmirror` code-server binary | `registry.npmmirror.com/-/binary/code-server` | 404 (not mirrored) |

## Bootstrap order for ca-certificates

The chicken-and-egg: HTTPS mirrors fail before `ca-certificates` is installed.

1. Write `sources.list` with `http://mirrors.aliyun.com/ubuntu` (HTTP, no cert check) + `[allow-insecure=yes]`.
2. `apt-get update && apt-get install -y ca-certificates`.
3. Rewrite `sources.list` to `https://mirrors.aliyun.com/ubuntu`.
4. `apt-get update` again.

## code-server install (npm fails due to git+ssh)

`npm i -g code-server` pulls `@parcel/watcher` via `git+ssh://github.com/...` (blocked in CN). Bypass:

1. Download release tarball via `gh-proxy.com`:
   `https://gh-proxy.com/https://github.com/coder/code-server/releases/download/v4.106.3/code-server-4.106.3-linux-amd64.tar.gz`
2. Extract to `/usr/local/lib/`, symlink binary to `/usr/local/bin/code-server`.
3. systemd service `code-server@<user>.service`.

Node.js v22 is required (latest code-server rejects v20). Install Node v22 from npmmirror binary, NOT apt (apt has older).
