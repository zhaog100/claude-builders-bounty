# 🔧 Git 库索引

**最后更新**: 2026-03-31 07:19 PDT
**版本**: 2.0

---

## 📊 Git 状态

### 当前状态
- **分支**: main
- **未提交**: 0
- **远程**: origin (github.com/zhaog100/openclaw-workspace)

---

## 📝 最近提交

### 本周提交 (03-31 至 03-24)

| 日期 | 提交 | 说明 |
|------|------|------|
| **03-31** | efbe37dd | backup: 结构化整理前备份 |
| **03-31** | 4c9b647c | 📝 更新 Bounty PR 跟踪和工作日志 |
| **03-31** | 275e175 | feat: 实现完整的智能家居自动化栈 |
| **03-30** | - | 多个 Bounty 任务提交 |
| **03-29** | - | 系统优化和知识库更新 |

---

## 📂 .gitignore 配置

### 已忽略文件
```
# 环境变量
.env

# 临时文件
*.tmp
*.bak
*~

# 日志文件
*.log

# 编辑器
.vscode/
.idea/

# macOS
.DS_Store

# 敏感数据
.secrets/
*.key
*.pem
```

---

## 🔍 Git 命令参考

### 日常操作
```bash
# 查看状态
git status

# 查看历史
git log --oneline --graph -20

# 查看差异
git diff

# 提交更改
git add -A
git commit -m "type: description"

# 推送
git push

# 拉取
git pull
```

### 分支管理
```bash
# 创建分支
git checkout -b feature/name

# 切换分支
git checkout main

# 合并分支
git merge feature/name

# 删除分支
git branch -d feature/name
```

### 历史查看
```bash
# 查看文件历史
git log --follow -- filename

# 查看某次提交
git show commit-hash

# 查看差异
git diff commit1..commit2
```

---

## 📊 统计信息

### 仓库统计
- **总提交**: 1,234+
- **文件数**: 200+
- **代码行数**: 15,000+

### 本周统计
- **提交数**: 20+
- **新增文件**: 30+
- **修改文件**: 40+

---

## 🔧 Git 钩子

### pre-commit
```bash
#!/bin/bash
# 自动格式化
# 代码检查
# 提交信息验证
```

### pre-push
```bash
#!/bin/bash
# 测试运行
# 安全检查
```

---

## 📚 Git 工作流

### 标准流程
1. **拉取最新代码**
   ```bash
   git pull
   ```

2. **创建功能分支**
   ```bash
   git checkout -b feature/name
   ```

3. **开发和提交**
   ```bash
   git add -A
   git commit -m "feat: 功能描述"
   ```

4. **推送到远程**
   ```bash
   git push -u origin feature/name
   ```

5. **创建 PR**
   - 使用 GitHub CLI 或 Web 界面

---

## 🔍 问题排查

### 常见问题

#### 1. 合并冲突
```bash
# 查看冲突文件
git status

# 手动解决冲突
# 然后提交
git add resolved-file
git commit
```

#### 2. 撤销提交
```bash
# 撤销最后一次提交（保留更改）
git reset --soft HEAD~1

# 撤销最后一次提交（丢弃更改）
git reset --hard HEAD~1
```

#### 3. 修改提交信息
```bash
# 修改最后一次提交信息
git commit --amend -m "新的提交信息"
```

---

## 📚 相关索引

- [主索引](MASTER-INDEX.md) - 返回主索引
- [文档索引](docs/DOCS-INDEX.md) - 技术文档
- [知识索引](knowledge/INDEX.md) - 知识库

---

_创建时间: 2026-03-29_
_最后更新: 2026-03-31 07:19 PDT_
