# 📚 主索引 (MASTER-INDEX)

**最后更新**: 2026-03-31 19:50 PDT
**版本**: 2.0

---

## 🎯 快速导航

### 📝 核心文件

| 文件 | 用途 | 更新频率 |
|------|------|----------|
| [MEMORY.md](MEMORY.md) | 长期记忆 | 重要事件 |
| [AGENTS.md](AGENTS.md) | 工作指南 | 按需 |
| [SOUL.md](SOUL.md) | 身份定义 | 很少 |
| [USER.md](USER.md) | 用户信息 | 按需 |
| [HEARTBEAT.md](HEARTBEAT.md) | 定时任务 | 按需 |
| [INDEX.md](INDEX.md) | 项目索引 | 按需 |

---

## 📂 分类索引

### 1️⃣ 记忆系统 (memory/)

**每日日志** (按时间倒序):
- [2026-03-31.md](memory/2026-03-31.md) - 今日工作
- [2026-03-30.md](memory/2026-03-30.md) - Bounty 任务 ($450+)
- [2026-03-29.md](memory/2026-03-29.md) - 系统优化

**深度审查**:
- [deep-review-2026-03-31.md](memory/deep-review-2026-03-31.md)
- [deep-review-2026-03-30.md](memory/deep-review-2026-03-30.md)

**索引**:
- [INDEX.md](memory/INDEX.md) - 记忆索引

---

### 2️⃣ 知识库 (knowledge/)

**核心知识**:
- [bounty/](knowledge/bounty/) - Bounty 知识库
  - [references/](knowledge/bounty/references/) - 参考文档
  - [templates/](knowledge/bounty/templates/) - 模板文件
- [api/](knowledge/api/) - API 文档
- [ai-skills/](knowledge/ai-skills/) - AI 技能
- [ai-system-design/](knowledge/ai-system-design/) - 系统设计

**索引**:
- [KNOWLEDGE-INDEX.md](knowledge/KNOWLEDGE-INDEX.md) - 知识索引

---

### 3️⃣ 数据目录 (data/)

**Bounty 数据**:
- [bounty-pr-tracker.json](data/bounty-pr-tracker.json) - PR 跟踪 ⭐
- [bounty-known-issues.txt](data/bounty-known-issues.txt) - 已知问题
- [bounty-queue/](data/bounty-queue/) - 任务队列

**支付数据**:
- [payment/](data/payment/) - 支付记录
- [payment-config.json](data/payment-config.json) - 支付配置

**监控数据**:
- [power-logs/](data/power-logs/) - 功耗数据
- [system-logs/](data/system-logs/) - 系统日志

**索引**:
- [INDEX.md](data/INDEX.md) - 数据索引

---

### 4️⃣ 文档目录 (docs/)

**技术文档**:
- [github-bounty-hunter-implementation.md](docs/github-bounty-hunter-implementation.md) - Bounty 实现
- [GIT_SETUP_GUIDE.md](docs/GIT_SETUP_GUIDE.md) - Git 设置
- [CODE_QUALITY_CHECKLIST.md](docs/CODE_QUALITY_CHECKLIST.md) - 代码质量

**索引**:
- [DOCS-INDEX.md](docs/DOCS-INDEX.md) - 文档索引

---

## 🔍 快速访问

### Bounty 任务

**当前任务**:
- [illbnm/homelab-stack #12](data/bounty-pr-tracker.json#L4) - Backup & DR ($150) ✅ PR #398
- [illbnm/homelab-stack #7](data/bounty-pr-tracker.json#L18) - Home Automation ($130) ✅ PR #401

**安全事件** (2026-03-31):
- 🔴 API Key 泄露 → ✅ 已修复并轮换所有密钥
- 📄 报告: `data/reports/security-scan-deep-2026-03-31.md`

**历史任务**:
- [RustChain #1589](data/bounty-pr-tracker.json#L32) - 已合并，等待付款

**队列**:
- [高价值任务](data/bounty-queue/queue_cleaned.json) - 评分 > 50

---

### 常用命令

```bash
# 查看 PR 状态
cat data/bounty-pr-tracker.json | jq '.prs[] | select(.status == "open")'

# 查看今日日志
cat memory/2026-03-31.md

# 查看功耗数据
tail -20 data/power-logs/power-data.csv

# 更新索引
make update-index
```

---

## 📊 统计信息

### 文件统计

| 目录 | 文件数 | 说明 |
|------|--------|------|
| memory/ | 17 | 日志文件 |
| knowledge/ | 50+ | 知识文档 |
| data/ | 30+ | 数据文件 |
| docs/ | 67 | 技术文档 |

### Git 统计

- **总提交**: 1,250+
- **今日提交**: 12
- **未提交**: 0
- **分支**: main

---

## 🔄 维护

### 每日
- 更新 memory/YYYY-MM-DD.md
- 检查 HEARTBEAT.md

### 每周
- 清理临时文件
- 更新索引

### 每月
- 归档旧日志
- 优化结构

---

## 📞 联系方式

- **用户**: QQ 机器人
- **渠道**: 直接消息
- **时区**: America/Los_Angeles (PDT)

---

_创建时间: 2026-03-29_
_最后更新: 2026-03-31 07:19 PDT_
