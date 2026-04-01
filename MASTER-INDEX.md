# 📚 主索引 (MASTER-INDEX)

**最后更新**: 2026-04-01 15:05 CST
**版本**: 3.0

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
- [2026-03-31.md](memory/2026-03-31.md) - S 级任务完成 ⭐
- [2026-03-30.md](memory/2026-03-30.md) - Bounty 任务高峰日
- [2026-03-29.md](memory/2026-03-29.md) - 系统优化 + Bounty 扫描

**深度审查**:
- [deep-review-2026-03-31.md](memory/deep-review-2026-03-31.md)
- [deep-review-2026-03-31-evening.md](memory/deep-review-2026-03-31-evening.md)

**索引**:
- [INDEX.md](memory/INDEX.md) - 记忆索引

---

### 2️⃣ 知识库 (knowledge/)

**核心知识**:
- [bounty/](knowledge/bounty/) - Bounty 知识库 ⭐
  - [standards/](knowledge/bounty/standards/) - 质量标准 v2.0
  - [strategies/](knowledge/bounty/strategies/) - 策略文档
  - [references/](knowledge/bounty/references/) - 参考文档
  - [templates/](knowledge/bounty/templates/) - 模板文件
- [api/](knowledge/api/) - API 文档
- [ai-skills/](knowledge/ai-skills/) - AI 技能
- [ai-system-design/](knowledge/ai-system-design/) - 系统设计
- [system-optimization/](knowledge/system-optimization/) - 系统优化 ⭐

**索引**:
- [KNOWLEDGE-INDEX.md](knowledge/KNOWLEDGE-INDEX.md) - 知识索引

---

### 3️⃣ 数据目录 (data/)

**Bounty 数据**:
- [bounty-pr-tracker.json](data/bounty-pr-tracker.json) - PR 跟踪 ⭐
- [bounty-known-issues.txt](data/bounty-known-issues.txt) - 已知问题
- [bounty-queue/](data/bounty-queue/) - 任务队列
- [bounty-scan-results-v2.md](data/bounty-scan-results-v2.md) - 扫描结果 v2.0

**支付数据**:
- [payment/](data/payment/) - 支付记录
- [payment-config.json](data/payment-config.json) - 支付配置

**监控数据**:
- [power-logs/](data/power-logs/) - 功耗数据
- [system-logs/](data/system-logs/) - 系统日志

**报告**:
- [reports/](data/reports/) - 各类报告

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

### 🌟 今日亮点（2026-03-31）

**S 级任务完成** ⭐⭐⭐⭐⭐:
- **仓库**: BerriAI/litellm（41,725 stars）
- **Issue**: #24530（CVSS 7.5 安全漏洞）
- **修复**: 三阶段深度防御
  - ✅ Phase 1: 默认启用认证
  - ✅ Phase 2: 清理 PII 标签
  - ✅ Phase 3: 添加启动警告
- **PR**: https://github.com/BerriAI/litellm/pull/24895
- **影响**: 防止多租户 PII 泄露

**Bounty 任务**:
- ✅ #12: Backup & DR ($150) - PR #398
- ✅ #7: Home Automation ($130) - 待推送

**系统优化**:
- ✅ 内存优化: +802MB
- ✅ 负载降低: -54%
- ✅ 结构化整理: 6 个索引

---

### Bounty 任务跟踪

**当前任务**:
- [illbnm/homelab-stack #12](data/bounty-pr-tracker.json#L4) - Backup & DR ($150) ✅ PR #398
- [illbnm/homelab-stack #7](data/bounty-pr-tracker.json#L18) - Home Automation ($130) ✅ 本地完成

**历史任务**:
- [RustChain #1589](data/bounty-pr-tracker.json#L32) - 已合并，等待付款
- [The-Pantseller/StarEscrow #198](data/bounty-pr-tracker.json#L46) - SECURITY.md ✅

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

# Git 推送
git push
```

---

## 📊 统计信息

### 文件统计

| 目录 | 文件数 | 说明 |
|------|--------|------|
| memory/ | 20+ | 日志文件 |
| knowledge/ | 60+ | 知识文档 |
| data/ | 40+ | 数据文件 |
| docs/ | 70+ | 技术文档 |
| skills/ | 60+ | 技能包 |

### Git 统计

- **总提交**: 1,270+
- **今日提交**: 20
- **待推送**: 2
- **分支**: main（master 已删除）

---

## 🔄 维护

### 每日
- 更新 memory/YYYY-MM-DD.md
- 检查 HEARTBEAT.md
- 推送 Git 提交

### 每周
- 清理临时文件
- 更新索引
- 结构化整理

### 每月
- 归档旧日志
- 优化结构
- 轮换密钥

---

## 📞 联系方式

- **用户**: QQ 机器人
- **渠道**: 直接消息
- **时区**: Asia/Shanghai (CST)

---

_创建时间: 2026-03-29_
_最后更新: 2026-04-01 15:05 CST_
