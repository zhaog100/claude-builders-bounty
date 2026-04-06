# 百炼 API 使用指南

> 阿里云百炼 Qwen3.5-Plus 模型集成
> 更新时间: 2026-04-06

---

## ✅ 配置状态

- **端点**: `https://coding.dashscope.aliyuncs.com/v1`
- **模型**: `qwen3.5-plus`
- **状态**: ✅ 可用
- **特点**: 100万上下文窗口

---

## 🔑 配置文件

**位置**: `~/.openclaw/workspace/.env`

```bash
BAILIAN_API_KEY="sk-sp-****...****ad5"
```

---

## 📝 调用示例

### Bash (curl)

```bash
source ~/.openclaw/workspace/.env

curl -X POST "https://coding.dashscope.aliyuncs.com/v1/chat/completions" \
  -H "Authorization: Bearer $BAILIAN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen3.5-plus",
    "messages": [
      {"role": "user", "content": "你好"}
    ]
  }'
```

### Python (requests)

```python
import os
import requests
from dotenv import load_dotenv

load_dotenv('~/.openclaw/workspace/.env')

response = requests.post(
    'https://coding.dashscope.aliyuncs.com/v1/chat/completions',
    headers={
        'Authorization': f"Bearer {os.getenv('BAILIAN_API_KEY')}",
        'Content-Type': 'application/json'
    },
    json={
        'model': 'qwen3.5-plus',
        'messages': [
            {'role': 'user', 'content': '你好'}
        ]
    }
)

print(response.json()['choices'][0]['message']['content'])
```

---

## 🎯 应用场景

### 1. Bounty 扫描
- **代码质量评估**: 分析项目代码质量
- **安全分析**: 识别潜在安全漏洞
- **项目分析**: 评估项目活跃度

### 2. 开发辅助
- **代码审查**: 自动化代码审查
- **文档生成**: 生成 API 文档
- **测试用例**: 自动生成测试用例

### 3. 数据分析
- **日志分析**: 分析系统日志
- **报告生成**: 自动生成报告
- **趋势预测**: 预测项目趋势

---

## 🔧 测试脚本

**位置**: `scripts/test_bailian_api.sh`

```bash
# 测试 API 连接
./scripts/test_bailian_api.sh
```

---

## ⚠️ 注意事项

1. **端点选择**:
   - ✅ 使用 `coding.dashscope.aliyuncs.com/v1`
   - ❌ 不要使用 `dashscope.aliyuncs.com/compatible-mode/v1`

2. **模型名称**:
   - ✅ 使用 `qwen3.5-plus`
   - ❌ 不要使用 `qwen-plus` 或其他变体

3. **配额管理**:
   - 监控每月使用量
   - 避免超出配额限制

---

## 📊 性能对比

| 模型 | 上下文 | 成本 | 速度 | 质量 |
|------|--------|------|------|------|
| qwen3.5-plus | 100万 | 免费(预览) | 快 | 高 |
| qwen-max | 100万 | 付费 | 中 | 最高 |
| qwen-turbo | 8K | 免费 | 最快 | 中 |

---

## 🚀 推荐配置

**Bounty 扫描**: `qwen3.5-plus` (性价比最高)
**复杂分析**: `qwen-max` (质量最高)
**快速扫描**: `qwen-turbo` (速度最快)

---

_最后更新: 2026-04-06 20:15 PDT_
