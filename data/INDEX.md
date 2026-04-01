# 📊 数据目录索引

**最后更新**: 2026-03-31 19:50 PDT
**版本**: 2.0

---

## 📂 数据分类

### 1️⃣ Bounty 数据 (核心)

#### PR 跟踪
- **[bounty-pr-tracker.json](bounty-pr-tracker.json)** - PR 状态跟踪 ⭐
  - 当前 PR: 12 个
  - 状态: open (8), merged (1), closed (3)

#### 任务队列
- **[bounty-queue/](bounty-queue/)** - 任务队列目录
  - `queue_cleaned.json` - 清理后的队列
  - `queue-submitted-backup.json` - 已提交备份

#### 已知问题
- **[bounty-known-issues.txt](bounty-known-issues.txt)** - 已处理 issues 黑名单
  - 记录数: 100+

#### 扫描结果
- **[bounty-scan-results-2026-03-31.md](bounty-scan-results-2026-03-31.md)** - 今日扫描
- **[bounty-scan-status.txt](bounty-scan-status.txt)** - 扫描状态

---

### 2️⃣ 支付数据

#### 配置文件
- **[payment-config.json](payment-config.json)** - 支付钱包配置
  - USDT (TRC20)
  - RTC

#### 支付记录
- **[payment/](payment/)** - 支付记录目录
  - 待付款项目
  - 已付款项目

---

### 3️⃣ 监控数据

#### 功耗监控
- **[power-logs/](power-logs/)** - 功耗数据目录
  - `power-data.csv` - 功耗数据 (5分钟间隔)
  - 最新记录: 2026-03-31 05:55:31

#### 系统日志
- **[system-logs/](system-logs/)** - 系统日志目录
  - 性能数据
  - 健康检查

---

### 4️⃣ 其他数据

#### 任务看板
- **[TASK_BOARD.md](TASK_BOARD.md)** - 任务看板
  - 进行中任务
  - 待办任务

#### 仓库黑名单
- **[bounty-repo-blacklist.txt](bounty-repo-blacklist.txt)** - 不处理仓库列表

#### SigNoz 演示
- **[signoz-demos/](signoz-demos/)** - SigNoz 演示数据

---

### 5️⃣ 报告数据

#### 安全报告
- **[reports/](reports/)** - 安全和审计报告 ⭐
  - `api-keys-to-rotate.md` - 待轮换密钥清单
  - `security-scan-deep-2026-03-31.md` - 深度安全扫描
  - `security-audit-2026-03-31.md` - 安全审计报告
  - `sensitive-data-masking-implementation-2026-03-31.md` - 脱敏实现

#### 集成报告
- **[reports/](reports/)** - 集成和配置报告
  - `gmail-integration-2026-03-31.md` - Gmail 集成
  - `github-token-update-2026-03-31.md` - GitHub Token 更新

#### 任务报告
- **[reports/](reports/)** - 任务相关报告
  - `high-value-tasks-2026-03-31.md` - 高价值任务清单

---

## 🔍 快速访问

### 查看 PR 状态
```bash
# 所有打开的 PR
cat data/bounty-pr-tracker.json | jq '.prs[] | select(.status == "open")'

# 今日提交的 PR
cat data/bounty-pr-tracker.json | jq '.prs[] | select(.submitted == "2026-03-31")'

# 已合并但未付款的 PR
cat data/bounty-pr-tracker.json | jq '.prs[] | select(.status == "merged" and .payment_status == "overdue")'
```

### 查看队列
```bash
# 高价值任务（评分 > 50）
cat data/bounty-queue/queue_cleaned.json | jq '.[] | select(.score > 50)'

# 按评分排序
cat data/bounty-queue/queue_cleaned.json | jq 'sort_by(.score) | reverse | .[0:10]'
```

### 查看功耗数据
```bash
# 最新 10 条记录
tail -10 data/power-logs/power-data.csv

# 今日平均功耗
cat data/power-logs/power-data.csv | grep "2026-03-31" | awk -F',' '{sum+=$3; count++} END {print "平均功耗:", sum/count, "W"}'
```

---

## 📊 统计信息

### Bounty 统计（截至 2026-03-31）
- **总 PR**: 12 个
- **今日新增**: 2 个（#398, #401）
- **总金额**: $1,840+（+$280 今日）
- **等待审核**: 10 个
- **已合并**: 1 个
- **已关闭**: 1 个

### 队列统计
- **总任务**: 50+
- **高价值**: 20+
- **已提交**: 30+

### 安全统计
- **已泄露密钥**: 2 个
- **已轮换密钥**: 4 个（Gemini, GitHub, Gmail, QQBot）
- **安全报告**: 7 个

---

## 🔧 维护

### 每日
- 更新 PR 状态
- 记录新提交

### 每周
- 清理队列
- 归档旧数据

### 每月
- 备份重要数据
- 清理临时文件

---

## 📚 相关索引

- [主索引](../MASTER-INDEX.md) - 返回主索引
- [记忆索引](../memory/INDEX.md) - 记忆系统
- [知识索引](../knowledge/INDEX.md) - 知识库

---

_创建时间: 2026-03-29_
_最后更新: 2026-03-31 07:19 PDT_
