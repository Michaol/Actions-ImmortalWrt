# ImmortalWrt TCP Brutal 集成指南

> 本指南用于在 Actions-ImmortalWrt 项目中集成 TCP Brutal 内核模块支持

## 概述

TCP Brutal 是一种激进的拥塞控制算法，在高丢包环境下可显著提升速度（相比 BBR 可提升 2-3 倍）。

---

## 步骤 1: 修改 diy-part1.sh

在 `diy-part1.sh` 文件末尾添加以下内容：

```bash
# 添加 TCP Brutal feeds 源
echo "src-git tcp_brutal https://github.com/haruue-net/openwrt-tcp-brutal.git;master" >> feeds.conf.default
```

**完整示例**（如果你的 diy-part1.sh 已有内容，只需在末尾追加）：

```bash
#!/bin/bash
#
# ... 现有内容 ...
#

# 添加 TCP Brutal feeds 源
echo "src-git tcp_brutal https://github.com/haruue-net/openwrt-tcp-brutal.git;master" >> feeds.conf.default
```

---

## 步骤 2: 修改 .config

在 `.config` 文件末尾添加以下内容：

```ini
# TCP Brutal Support (for high packet loss networks)
CONFIG_PACKAGE_kmod-brutal=y
```

---

## 步骤 3: 提交并推送

```bash
git add diy-part1.sh .config
git commit -m "feat: add TCP Brutal kernel module support"
git push
```

---

## 步骤 4: 触发 GitHub Actions 编译

1. 前往 GitHub 仓库的 **Actions** 页面
2. 选择编译工作流并手动触发
3. 等待编译完成

---

## 步骤 5: 验证安装

固件刷入路由器后，执行以下命令验证：

```bash
# 检查模块是否存在
ls /lib/modules/*/brutal.ko 2>/dev/null && echo "✓ 模块已安装" || echo "✗ 模块未找到"

# 加载模块
modprobe brutal

# 验证模块已加载
lsmod | grep brutal
```

---

## 步骤 6: 配置 sing-box 使用 Brutal

### 客户端配置（路由器端）

在 HomeProxy 或 sing-box 的 outbound 配置中启用 Brutal：

```json
{
  "type": "vless",
  "tag": "proxy",
  "server": "your-server.com",
  "server_port": 443,
  "uuid": "your-uuid",
  "flow": "",
  "tls": {
    "enabled": true,
    "server_name": "your-server.com",
    "utls": {
      "enabled": true,
      "fingerprint": "chrome"
    }
  },
  "multiplex": {
    "enabled": true,
    "protocol": "h2mux",
    "max_connections": 4,
    "min_streams": 4,
    "padding": true,
    "brutal": {
      "enabled": true,
      "up_mbps": 50,
      "down_mbps": 100
    }
  }
}
```

### 参数说明

| 参数        | 说明                                     |
| ----------- | ---------------------------------------- |
| `up_mbps`   | 上传带宽（Mbps），设置为你的实际上传带宽 |
| `down_mbps` | 下载带宽（Mbps），设置为你的实际下载带宽 |
| `protocol`  | 推荐使用 `h2mux`，兼容性最好             |

### 服务端配置

服务端 sing-box 的 inbound 也需要启用 Brutal 支持：

```json
{
  "type": "vless",
  "tag": "vless-in",
  "listen": "::",
  "listen_port": 443,
  "users": [
    {
      "uuid": "your-uuid"
    }
  ],
  "tls": {
    "enabled": true,
    "certificate_path": "/path/to/cert.pem",
    "key_path": "/path/to/key.pem"
  },
  "multiplex": {
    "enabled": true,
    "padding": true,
    "brutal": {
      "enabled": true,
      "up_mbps": 1000,
      "down_mbps": 1000
    }
  }
}
```

> **服务端带宽值**：应设置为服务器的实际带宽上限

---

## 注意事项

1. **每次固件升级后需重新编译** - 内核模块与内核版本绑定
2. **服务端必须同时支持** - 客户端和服务端都需要配置 Brutal
3. **带宽设置要准确** - 设置过高会导致拥塞，设置过低会限制速度
4. **流量特征明显** - Brutal 的流量特征比 BBR 更容易被识别

---

## 快速复制区

### diy-part1.sh 追加行

```bash
echo "src-git tcp_brutal https://github.com/haruue-net/openwrt-tcp-brutal.git;master" >> feeds.conf.default
```

### .config 追加行

```ini
CONFIG_PACKAGE_kmod-brutal=y
```

---

## 参考链接

- [haruue-net/openwrt-tcp-brutal](https://github.com/haruue-net/openwrt-tcp-brutal)
- [sing-box Multiplex 文档](https://sing-box.sagernet.org/configuration/shared/multiplex/)
