# AI 辅助 Bounty 扫描器 - 使用指南

**版本**: v1.0
**创建时间**: 2026-04-01 16:50 CST

---

## 📋 概述

集成 OpenRouter API (Qwen3.6 Plus) 到 Bounty 扫描系统， 提供 AI 辅助的任务价值评估、代码审查和安全分析功能。

---

## 🚀 快速开始

### 1. 获取 OpenRouter API Key

1. 访问: https://openrouter.ai/keys
2. 创建免费 API Key
3. 复制 Key（格式: `sk-or-...`)

---

### 2. 配置环境变量

```bash
# 编辑 .env 文件
vi ~/.openclaw/workspace/.env

# 添加以下内容
OPENROUTER_API_KEY=sk-or-your-api-key-here
```

---

### 3. 测试连接

```bash
# 测试 API 连接
./scripts/ai_assisted_scanner.sh config

# 测试评估功能
./scripts/ai_assisted_scanner.sh assess BerriAI/litellm 24530 "Security issue" "测试"
```

---

## 📖 功能说明

### 1️⃣ 任务价值评估

**用途**: 使用 AI 分析 bounty 任务的价值

**维度**:
- 技术难度 (1-10分)
- 市场价值 (1-10分)
- 学习价值 (1-10分)
- 完成时间估计
- 总体评分

**使用**:
```bash
./scripts/ai_assisted_scanner.sh assess <repo> <issue_number> [title] [body]
```

**示例**:
```bash
./scripts/ai_assisted_scanner.sh assess BerriAI/litellm 24530 \
  "Security: Metrics endpoint exposed without auth" \
  "The metrics endpoint in LiteLLM exposes sensitive information..."
```

---

### 2️⃣ AI 代码审查

**用途**: 使用 AI 审查代码质量

**维度**:
- 代码质量 (1-10分)
- 潜在安全问题
- 性能问题
- 改进建议
- 总体评价

**使用**:
```bash
./scripts/ai_assisted_scanner.sh review <file>
```

**示例**:
```bash
./scripts/ai_assisted_scanner.sh review litellm/proxy/proxy_server.py
```

---

### 3️⃣ AI 安全分析

**用途**: 使用 AI 分析代码安全问题

**维度**:
- SQL 注入
- XSS
- 认证绕过
- 数据泄露
- 其他安全问题

**使用**:
```bash
./scripts/ai_assisted_scanner.sh security <file>
```

**示例**:
```bash
./scripts/ai_assisted_scanner.sh security litellm/proxy/proxy_server.py
```

---

### 4️⃣ 生成报告

**用途**: 使用 AI 生成分析报告

**使用**:
```bash
./scripts/ai_assisted_scanner.sh report <results_file> <output_file>
```

**示例**:
```bash
./scripts/ai_assisted_scanner.sh report data/scan-results.json data/ai-report.md
```

---

### 5️⃣ 集成到扫描器

**用途**: 将 AI 分析集成到 bounty 扫描器

**使用**:
```bash
cat data/scan-results.json | ./scripts/ai_assisted_scanner.sh integrate
```

---

## ⚙️ 配置说明

### 配置文件位置

```
~/.openclaw/workspace/.ai-scanner-config.json
```

### 配置参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `api_provider` | string | "openrouter" | API 提供商 |
| `model` | string | "qwen/qwen3.6-plus-preview:free" | 模型名称 |
| `max_tokens` | int | 4000 | 最大生成 token 数 |
| `temperature` | float | 0.7 | 温度参数 |
| `enable_code_review` | bool | true | 启用代码审查 |
| `enable_security_analysis` | bool | true | 启用安全分析 |
| `enable_value_assessment` | bool | true | 启用价值评估 |
| `cache_ai_responses` | bool | true | 缓存 AI 响应 |
| `cache_ttl_hours` | int | 24 | 缓存有效期（小时）|

### 更新配置

```bash
# 使用编辑器修改
vi ~/.openclaw/workspace/.ai-scanner-config.json

# 或使用 jq
jq '.max_tokens = 8000' .ai-scanner-config.json > .ai-scanner-config.json.tmp && \
   mv .ai-scanner-config.json.tmp .ai-scanner-config.json
```

---

## 🔄 与 bounty 扫描器集成

### 方法 1: 管道集成

```bash
# 扫描 → AI 分析 → 生成报告
./scripts/bounty_unified_scanner.sh batch data/repo-list.txt | \
  ./scripts/ai_assisted_scanner.sh integrate | \
  jq '.[] | select(.ai_assessment.overall_score > 8)' > data/high-value-tasks.json
```

### 方法 2: 修改 bounty 扫描器

在 `bounty_unified_scanner.sh` 中添加 AI 分析步骤：

---

## 📊 成本分析

### OpenRouter 免费额度

- ✅ **完全免费**（目前）
- ✅ **无限次数**（预览期）
- ⚠️ **未来可能收费**（预览期结束后）

### 缓存策略

- ✅ 相同请求缓存 24 小时
- ✅ 减少重复 API 调用
- ✅ 节省成本（未来收费后）

---

## 🐛 故障排查

### 问题 1: API Key 无效

**症状**:
```
API 调用失败: Invalid API key
```

**解决**:
```bash
# 检查 API Key 格式
echo $OPENROUTER_API_KEY | grep '^sk-or-'

# 重新生成 API Key
# 访问: https://openrouter.ai/keys
```

---

### 问题 2: 网络超时

**症状**:
```
API 调用失败: Connection timeout
```

**解决**:
- 检查网络连接
- 使用代理或 VPN
- 增加超时时间

---

### 问题 3: 缓存问题

**症状**:
```
缓存响应错误
```

**解决**:
```bash
# 清理缓存
rm -rf ~/.openclaw/workspace/.cache/ai-cache-*.json
```

---

## 📚 最佳实践

### 1. 批量处理

```bash
# 批量评估任务价值
cat data/tasks.txt | while read repo number title body; do
  ./scripts/ai_assisted_scanner.sh assess "$repo" "$number" "$title" "$body"
done
```

### 2. 缓存利用

```bash
# 检查缓存状态
ls -lh ~/.openclaw/workspace/.cache/ai-cache-*.json

# 使用缓存（24 小时内有效）
./scripts/ai_assisted_scanner.sh assess BerriAI/litellm 24530 "..." "..."
```

### 3. 结果过滤

```bash
# 只显示高价值任务（总体评分 > 8）
cat data/ai-results.json | jq '.[] | select(.ai_assessment.overall_score > 8)'
```

---

## 🔐 安全注意事项

### 1. API Key 保护

- ✅ 不要在代码中硬编码 API Key
- ✅ 使用环境变量
- ✅ 定期轮换 API Key
- ✅ 限制 API Key 权限

### 2. 代码上传

- ⚠️ 不要上传敏感代码到 API
- ⚠️ 审查代码中是否有密钥、密码等
- ✅ 使用 `.gitignore` 排除敏感文件

### 3. 缓存安全

- ✅ 缓存文件存储在本地
- ✅ 不要将缓存提交到 Git
- ✅ 定期清理敏感缓存

---

## 📈 性能优化

### 1. 并行处理

```bash
# 并行评估多个任务
cat data/tasks.txt | xargs -P 3 -I {} ./scripts/ai_assisted_scanner.sh assess {}
```

### 2. 批量 API 调用

```bash
# 批量处理（减少 API 调用次数）
./scripts/ai_assisted_scanner.sh report data/batch-results.json data/batch-report.md
```

### 3. 缓存预热

```bash
# 预热缓存（常用任务）
cat data/common-tasks.txt | while read task; do
  ./scripts/ai_assisted_scanner.sh assess $task
done
```

---

## 🔄 更新日志

### v1.0 (2026-04-01)
- ✅ 初始版本
- ✅ 集成 OpenRouter API
- ✅ 支持 Qwen3.6 Plus
- ✅ 任务价值评估
- ✅ 代码审查
- ✅ 安全分析
- ✅ 报告生成
- ✅ 缓存系统

---

## 🤝 贡献

如需改进此工具，请更新以下文件：
1. 扫描脚本: `scripts/ai_assisted_scanner.sh`
2. 配置文件: `.ai-scanner-config.json`
3. 使用文档: `knowledge/ai-integration/AI-SCANNER-GUIDE.md`

---

_最后更新: 2026-04-01 16:50 CST_
