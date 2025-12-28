---
description: GitHub 操作偏好 - 使用 gh CLI 而非浏览器
---

# GitHub 操作规则

**所有 GitHub 操作必须通过 `gh` CLI 执行，而非浏览器操作。**

## 常用命令示例

### 触发工作流

```bash
gh workflow run <workflow-name>.yml --repo <owner>/<repo>
```

### 查看运行状态

```bash
gh run list --workflow="<workflow-name>.yml" --repo <owner>/<repo> -L 5
```

### 查看运行详情

```bash
gh run view <run-id> --repo <owner>/<repo>
```

### 查看运行日志

```bash
gh run view <run-id> --repo <owner>/<repo> --log
```

### 创建 Issue

```bash
gh issue create --title "标题" --body "内容" --repo <owner>/<repo>
```

### 创建 PR

```bash
gh pr create --title "标题" --body "内容" --repo <owner>/<repo>
```

### 查看仓库信息

```bash
gh repo view <owner>/<repo>
```
