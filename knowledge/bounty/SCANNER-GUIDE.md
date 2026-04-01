# Bounty 扫描系统使用指南

**版本**: v1.0
**更新时间**: 2026-04-01 16:15 CST
**作者**: AI Assistant

---

## 📋 概述

Bounty 统一扫描系统是一个自动化工具，用于扫描 GitHub 仓库中的高价值 bounty 任务。

### 核心功能

- ✅ **单仓库扫描**: 深度扫描指定仓库
- ✅ **批量扫描**: 并行扫描多个仓库
- ✅ **智能评分**: 基于标签、活跃度等因素计算评分
- ✅ **缓存系统**: 避免重复扫描
- ✅ **自动报告**: 生成 Markdown 格式的扫描报告
- ✅ **黑名单管理**: 跳过已知问题或仓库

---

## 🚀 快速开始

### 1. 初始化配置

```bash
# 首次运行会自动创建默认配置
./scripts/bounty_unified_scanner.sh config
```

### 2. 扫描单个仓库

```bash
# 扫描指定仓库
./scripts/bounty_unified_scanner.sh scan BerriAI/litellm

# 限制扫描的 issue 数量
./scripts/bounty_unified_scanner.sh scan BerriAI/litellm 20
```

### 3. 批量扫描

```bash
# 准备仓库列表文件
cat > data/repo-list.txt << EOF
BerriAI/litellm
illbnm/homelab-stack
Scottcjn/rustchain-bounties
EOF

# 执行批量扫描
./scripts/bounty_unified_scanner.sh batch data/repo-list.txt
```

---

## ⚙️ 配置说明

### 配置文件位置

```
~/.openclaw/workspace/.bounty-scanner-config.json
```

### 配置参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `min_score` | int | 70 | 最低评分阈值 |
| `max_repos_per_scan` | int | 50 | 每次扫描的最大仓库数 |
| `cache_ttl_hours` | int | 24 | 缓存有效期（小时）|
| `parallel_jobs` | int | 3 | 并行扫描数 |
| `timeout_seconds` | int | 300 | 单个仓库超时时间 |
| `enabled_categories` | array | ["security", "feature", "bug", "documentation"] | 启用的任务类别 |
| `priority_order` | array | ["security", "feature", "bug", "documentation"] | 优先级顺序 |
| `blacklist_repos` | array | [] | 仓库黑名单 |
| `blacklist_issues` | array | [] | Issue 黑名单 |

### 更新配置

```bash
# 使用编辑器修改
./scripts/bounty_unified_scanner.sh update-config

# 或直接编辑 JSON 文件
vi ~/.openclaw/workspace/.bounty-scanner-config.json
```

---

## 📊 评分算法

### 评分标准（总分 100）

#### 1. 标签权重（最高 75 分）

| 标签类型 | 分数 |
|----------|------|
| Security/Bounty/Bug-Bounty | +40 |
| Help Wanted/Good First Issue | +20 |
| High Priority/Urgent | +15 |

#### 2. 活跃度（最高 10 分）

| 评论数 | 分数 |
|--------|------|
| > 10 条评论 | +10 |
| 5-10 条评论 | +5 |

#### 3. 附加权重（待实现）

- 仓库活跃度（近期提交）
- 维护者响应速度
- 金额大小（如果有）
- 难度评估

---

## 🔧 高级用法

### 1. 自定义评分阈值

```bash
# 只扫描评分 >= 80 的任务
./scripts/bounty_unified_scanner.sh batch data/repo-list.txt --min-score 80
```

### 2. 调整并行度

```bash
# 增加并行扫描数到 5
./scripts/bounty_unified_scanner.sh batch data/repo-list.txt --parallel 5
```

### 3. 查看缓存状态

```bash
./scripts/bounty_unified_scanner.sh cache
```

### 4. 清理缓存

```bash
./scripts/bounty_unified_scanner.sh clean
```

---

## 📈 使用示例

### 场景 1: 每日扫描

```bash
# 创建每日扫描脚本
cat > scripts/daily-bounty-scan.sh << 'EOF'
#!/bin/bash
cd ~/.openclaw/workspace

# 更新仓库列表
./scripts/update-repo-list.sh > data/repo-list.txt

# 执行扫描
./scripts/bounty_unified_scanner.sh batch data/repo-list.txt

# 发送通知（可选）
# ./scripts/send-notification.sh "扫描完成"
EOF

chmod +x scripts/daily-bounty-scan.sh
```

### 场景 2: 安全类任务优先

```bash
# 修改配置，只扫描安全类任务
jq '.enabled_categories = ["security"]' \
   .bounty-scanner-config.json > .bounty-scanner-config.json.tmp && \
   mv .bounty-scanner-config.json.tmp .bounty-scanner-config.json

# 执行扫描
./scripts/bounty_unified_scanner.sh batch data/security-repos.txt
```

### 场景 3: 添加到黑名单

```bash
# 添加已处理的 issue 到黑名单
jq '.blacklist_issues += ["BerriAI/litellm#24530"]' \
   .bounty-scanner-config.json > .bounty-scanner-config.json.tmp && \
   mv .bounty-scanner-config.json.tmp .bounty-scanner-config.json
```

---

## 📝 输出格式

### 扫描报告示例

```markdown
# Bounty 扫描报告

**扫描时间**: 2026-04-01 16:30:00 CST
**配置**:
- 最低评分: 70
- 扫描仓库数: 50
- 发现任务数: 12

---

## 高价值任务

### [Add security headers to API endpoints](https://github.com/example/repo/issues/123)

- **仓库**: example/repo
- **Issue**: #123
- **评分**: 85
- **链接**: https://github.com/example/repo/issues/123

### [...]
```

---

## 🐛 故障排查

### 问题 1: GitHub API 限流

**症状**:
```
API rate limit exceeded
```

**解决**:
- 检查 GITHUB_TOKEN 是否有效
- 等待 1 小时后重试
- 减少并行扫描数

### 问题 2: 缓存过期

**症状**:
```
缓存数据过旧
```

**解决**:
```bash
./scripts/bounty_unified_scanner.sh clean
```

### 问题 3: jq 命令未找到

**解决**:
```bash
# macOS
brew install jq

# Linux
sudo apt-get install jq
```

---

## 🔐 安全注意事项

1. **API Token 保护**:
   - 不要在命令行中直接使用 token
   - 使用环境变量 `GITHUB_TOKEN`
   - 定期轮换 token

2. **黑名单管理**:
   - 定期清理黑名单
   - 记录添加原因

3. **日志审计**:
   - 定期检查扫描日志
   - 发现异常及时处理

---

## 📚 相关文档

- [Bounty 知识库](../knowledge/bounty/README.md)
- [质量评估标准](../knowledge/bounty/standards/quality-evaluation-v2.md)
- [安全模板](../knowledge/bounty/security-templates/)
- [PR 跟踪系统](../data/bounty-pr-tracker.json)

---

## 🔄 更新日志

### v1.0 (2026-04-01)
- ✅ 初始版本
- ✅ 统一所有扫描脚本
- ✅ 添加缓存系统
- ✅ 添加智能评分
- ✅ 添加并行扫描

---

## 🤝 贡献

如需改进此系统，请更新以下文件：
1. 扫描脚本: `scripts/bounty_unified_scanner.sh`
2. 配置文档: `knowledge/bounty/SCANNER-GUIDE.md`
3. 评分算法: `scripts/bounty_unified_scanner.sh` 中的 `calculate_score` 函数

---

_最后更新: 2026-04-01 16:15 CST_
