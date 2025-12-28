# TCP Brutal 哈希修复指南

> 由于上游 `apernet/tcp-brutal` 的 `v1.0.3` tag 被 force push 修改，导致哈希值不匹配，需要 Fork 仓库并更新哈希。

---

## 问题描述

```
Hash mismatch for file tcp-brutal-1.0.3.tar.zst:
  expected 0c7f5581da3bc5726bfd36a1f4863f77ca9a2684449d4b1d416577557b3d6f92
  got      2b666b71de07256449b3e967da63f48fdb0c1146194d8deaf7edb20a82a99811
```

**原因**：上游仓库 `haruue-net/openwrt-tcp-brutal` 中的 Makefile 定义的哈希值与实际源码不匹配。

---

## 修复步骤

### 步骤 1：Fork 上游仓库

1. 访问 https://github.com/haruue-net/openwrt-tcp-brutal
2. 点击右上角 **Fork** 按钮
3. 选择你的账户（Michaol）
4. 等待 Fork 完成，得到：`https://github.com/Michaol/openwrt-tcp-brutal`

---

### 步骤 2：修改 Makefile 中的哈希值

1. 在你 Fork 的仓库中，导航到 `kernel/tcp-brutal/Makefile`
2. 点击编辑（铅笔图标）
3. 找到这一行：
   ```makefile
   PKG_MIRROR_HASH:=0c7f5581da3bc5726bfd36a1f4863f77ca9a2684449d4b1d416577557b3d6f92
   ```
4. 修改为：
   ```makefile
   PKG_MIRROR_HASH:=2b666b71de07256449b3e967da63f48fdb0c1146194d8deaf7edb20a82a99811
   ```
5. 提交更改，commit message：`fix: update PKG_MIRROR_HASH for v1.0.3`

---

### 步骤 3：更新 Actions-ImmortalWrt 的 feeds 源

修改 `diy-part1.sh`，将 feeds 源指向你 Fork 的仓库：

**修改前：**

```bash
echo "src-git tcp_brutal https://github.com/haruue-net/openwrt-tcp-brutal.git;master" >> feeds.conf.default
```

**修改后：**

```bash
echo "src-git tcp_brutal https://github.com/Michaol/openwrt-tcp-brutal.git;master" >> feeds.conf.default
```

---

### 步骤 4：提交并推送

```bash
cd E:\DEV\Actions-ImmortalWrt
git add diy-part1.sh
git commit -m "fix: use forked tcp-brutal repo with correct hash"
git push
```

---

### 步骤 5：重新触发 GitHub Actions

1. 前往 https://github.com/Michaol/Actions-ImmortalWrt/actions
2. 手动触发编译工作流
3. 等待编译完成

---

## 快速复制区

### 新哈希值

```
2b666b71de07256449b3e967da63f48fdb0c1146194d8deaf7edb20a82a99811
```

### diy-part1.sh 修改后的行

```bash
echo "src-git tcp_brutal https://github.com/Michaol/openwrt-tcp-brutal.git;master" >> feeds.conf.default
```

---

## 后续维护

- 如果上游 `haruue-net/openwrt-tcp-brutal` 更新修复了哈希问题，可以切换回上游
- 如果 `apernet/tcp-brutal` 发布新版本，需要同步更新 Fork 仓库

---

## 参考链接

- [haruue-net/openwrt-tcp-brutal](https://github.com/haruue-net/openwrt-tcp-brutal)
- [apernet/tcp-brutal](https://github.com/apernet/tcp-brutal)
- [Merge pull request #23 - fix-kernel-6_10](https://github.com/apernet/tcp-brutal/pull/23)
