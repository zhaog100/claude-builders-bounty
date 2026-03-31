# 🧹 结构化整理计划

**整理时间**: 2026-03-31 07:06 PDT
**目标**: 系统化整理记忆、知识库、Git库、索引

---

## 📊 当前状态分析

### 1. 记忆系统 (memory/)
- ✅ 日志文件: 17 个（2026-03-20 至 2026-03-31）
- ⚠️ 重复索引: INDEX.md, MEMORY-INDEX.md
- ✅ 审查记录: audit-*, deep-review-*

### 2. 知识库 (knowledge/)
- ✅ 分类目录: 13 个
- ✅ 核心文档: KNOWLEDGE-INDEX.md
- ⚠️ 重复文件: README.md 多处

### 3. 数据目录 (data/)
- ✅ Bounty 数据: 20+ 文件
- ⚠️ 备份文件: 7 个 .bak 文件
- ⚠️ 临时文件: bounty-known-issues.txt

### 4. 文档目录 (docs/)
- ✅ 技术文档: 67 个
- ⚠️ 重复索引: DOCS-INDEX.md, KNOWLEDGE_INDEX.md

### 5. Git 状态
- ⚠️ 未提交文件: 待检查
- ⚠️ 大文件: 待优化

---

## 🎯 整理目标

### 1️⃣ 记忆系统
- [ ] 合并重复索引文件
- [ ] 归档 30 天前的日志
- [ ] 创建统一的记忆索引
- [ ] 建立命名规范

### 2️⃣ 知识库
- [ ] 删除重复的 README
- [ ] 优化目录结构
- [ ] 更新知识索引
- [ ] 添加分类标签

### 3️⃣ Git 库
- [ ] 提交所有变更
- [ ] 清理备份文件
- [ ] 优化 .gitignore
- [ ] 创建 Git 钩子

### 4️⃣ 索引系统
- [ ] 创建主索引 (MASTER-INDEX.md)
- [ ] 创建分类索引
  - [ ] 记忆索引 (MEMORY-INDEX.md)
  - [ ] 知识索引 (KNOWLEDGE-INDEX.md)
  - [ ] 数据索引 (DATA-INDEX.md)
  - [ ] Git 索引 (GIT-INDEX.md)
- [ ] 创建快速访问指南

---

## 📁 整理后的目录结构

```
/Users/zhaog/.openclaw/workspace/
├── 📝 核心文件
│   ├── MEMORY.md           # 长期记忆
│   ├── INDEX.md            # 主索引
│   ├── AGENTS.md           # 工作指南
│   ├── SOUL.md             # 身份定义
│   ├── USER.md             # 用户信息
│   └── HEARTBEAT.md        # 定时任务
│
├── 📚 memory/              # 每日日志
│   ├── 2026-03-XX.md       # 每日工作日志
│   ├── deep-review-*.md    # 深度审查
│   └── INDEX.md            # 记忆索引
│
├── 🧠 knowledge/           # 知识库
│   ├── bounty/             # Bounty 知识
│   ├── api/                # API 文档
│   ├── ai-skills/          # AI 技能
│   ├── system-optimization/# 系统优化
│   └── INDEX.md            # 知识索引
│
├── 📊 data/                # 数据文件
│   ├── bounty-*/           # Bounty 数据
│   ├── payment/            # 付款数据
│   ├── reports/            # 报告
│   └── INDEX.md            # 数据索引
│
├── 📖 docs/                # 文档
│   ├── guides/             # 指南
│   ├── references/         # 参考资料
│   └── INDEX.md            # 文档索引
│
└── 🔧 scripts/             # 脚本工具
    ├── utility/            # 实用工具
    └── automation/         # 自动化脚本
```

---

## ✅ 执行步骤

### Step 1: 备份当前状态
```bash
git add -A
git commit -m "backup: 整理前备份"
```

### Step 2: 清理重复文件
- 删除 .bak 文件
- 合并重复索引
- 归档旧文件

### Step 3: 重组目录结构
- 按类型分类
- 创建统一命名
- 建立索引系统

### Step 4: 更新索引
- 更新主索引
- 创建分类索引
- 添加快速访问

### Step 5: Git 提交
```bash
git add -A
git commit -m "refactor: 结构化整理完成"
git push
```

---

## 📊 预期效果

- ✅ 文件数量减少 30%
- ✅ 查找效率提升 50%
- ✅ 重复文件减少 80%
- ✅ 索引覆盖率 100%

---

## 🔄 维护计划

### 每日
- 更新 memory/YYYY-MM-DD.md

### 每周
- 清理临时文件
- 更新索引

### 每月
- 归档旧日志
- 优化目录结构

---

_创建时间: 2026-03-31 07:06 PDT_
