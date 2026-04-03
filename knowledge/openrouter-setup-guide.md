# OpenRouter 免费模型配置指南

**创建时间**: 2026-04-04 07:00 CST
**状态**: 配置指南

---

## 📋 配置步骤

### 第一步：注册 OpenRouter 账号

**访问**: https://openrouter.ai/

**注册方式**（任选一种）:
- ✅ Google 账号
- ✅ GitHub 账号
- ✅ Microsoft 账号
- ✅ 邮箱注册

**费用**: 完全免费

---

### 第二步：获取 API Key

1. **登录后访问**:
   https://openrouter.ai/keys

2. **创建 API Key**:
   - 点击 "Create Key" 按钮
   - 输入 Key 名称（如: "OpenClaw-Bounty"）
   - 点击 "Create"

3. **复制 API Key**:
   - 格式: `sk-or-v1-xxxxxxxxxxxxx`
   - **重要**: 立即复制，只显示一次！

---

### 第三步：配置到系统

**方式 1: 手动添加到 .env**

```bash
# 编辑配置文件
nano ~/.openclaw/workspace/.env

# 添加以下行
OPENROUTER_API_KEY=sk-or-v1-your-key-here

# 保存退出（Ctrl+O, Enter, Ctrl+X）
```

**方式 2: 使用命令添加**

```bash
echo "OPENROUTER_API_KEY=sk-or-v1-your-key-here" >> ~/.openclaw/workspace/.env
```

---

### 第四步：验证配置

**测试 API Key**:

```bash
curl https://openrouter.ai/api/v1/models \
  -H "Authorization: Bearer sk-or-v1-your-key-here"
```

**预期输出**:
```json
{
  "data": [
    {
      "id": "openai/gpt-3.5-turbo",
      "name": "OpenAI GPT-3.5 Turbo",
      ...
    },
    ...
  ]
}
```

---

## 🎯 可用免费模型

### 推荐免费模型

| 模型 | 提供商 | 特点 |
|------|--------|------|
| **qwen/qwen-2-7b-instruct:free** | Qwen | 中文友好，速度快 |
| **google/gemma-7b-it:free** | Google | 英文优秀，通用 |
| **meta-llama/llama-3-8b-instruct:free** | Meta | 最新 Llama 3 |
| **mistralai/mistral-7b-instruct:free** | Mistral | 欧洲开源模型 |
| **openchat/openchat-7b:free** | OpenChat | 对话优化 |

### 模型特点

**Qwen 系列**:
- ✅ 中文支持最好
- ✅ 免费，无限制
- ✅ 适合 Bounty 任务（中文场景）

**Llama 3 系列**:
- ✅ Meta 最新模型
- ✅ 性能优秀
- ✅ 通用能力强

**Gemma 系列**:
- ✅ Google 开源
- ✅ 轻量级
- ✅ 速度快

---

## 💰 成本对比

### 使用免费模型

- **成本**: $0
- **性能**: 中等（适合大部分任务）
- **速率限制**: 有（通常 20 req/min）

### 使用付费模型

- **成本**: $0.001-0.03 / 1K tokens
- **性能**: 高（GPT-4, Claude-3）
- **速率限制**: 较少

**建议**:
- ✅ 测试和学习 → 免费模型
- ✅ 简单任务 → 免费模型
- ⚠️ 复杂任务 → 付费模型（按需）

---

## 🚀 使用示例

### Python 调用

```python
import requests

api_key = "sk-or-v1-your-key-here"
model = "qwen/qwen-2-7b-instruct:free"

response = requests.post(
    "https://openrouter.ai/api/v1/chat/completions",
    headers={
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    },
    json={
        "model": model,
        "messages": [
            {"role": "user", "content": "Hello!"}
        ]
    }
)

print(response.json())
```

### cURL 调用

```bash
curl https://openrouter.ai/api/v1/chat/completions \
  -H "Authorization: Bearer sk-or-v1-your-key-here" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen/qwen-2-7b-instruct:free",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

---

## 🔒 安全提示

### API Key 保护

- ✅ 不要在代码中硬编码
- ✅ 使用环境变量存储
- ✅ 定期更换 API Key
- ✅ 不要分享给他人

### 日志脱敏

**正确做法**:
```python
# ✅ 只显示前缀和后4位
print(f"API Key: sk-or-v1-***...***{api_key[-4:]}")
```

**错误做法**:
```python
# ❌ 显示完整 Key
print(f"API Key: {api_key}")
```

---

## 📊 使用限制

### 免费模型限制

| 限制项 | 免费模型 | 付费模型 |
|--------|---------|----------|
| **请求频率** | 20 req/min | 60+ req/min |
| **Token 数量** | 无明确限制 | 按付费额度 |
| **并发数** | 1-2 | 10+ |
| **可用性** | 99% | 99.9% |

### 速率限制处理

```python
import time
import requests

def call_api_with_retry(prompt, max_retries=3):
    for i in range(max_retries):
        try:
            response = requests.post(...)
            if response.status_code == 429:  # Too Many Requests
                time.sleep(60)  # 等待 1 分钟
                continue
            return response.json()
        except Exception as e:
            if i == max_retries - 1:
                raise
            time.sleep(5)
```

---

## 🎯 Bounty 任务应用

### 适用场景

1. **代码生成**
   ```python
   model = "qwen/qwen-2-7b-instruct:free"
   prompt = "生成一个 Python 函数，实现..."
   ```

2. **文档写作**
   ```python
   prompt = "为这个项目写一个 README.md..."
   ```

3. **数据分析**
   ```python
   prompt = "分析这个 CSV 文件，找出..."
   ```

4. **测试用例生成**
   ```python
   prompt = "为这个函数生成测试用例..."
   ```

### 成本节约

**使用免费模型**:
- Bounty 任务 AI 成本: $0
- 节省比例: 100%

**对比付费模型**:
- GPT-4: $0.03 / 1K tokens
- Claude-3: $0.015 / 1K tokens
- 月成本: $50-200（中等使用频率）

---

## 📝 常见问题

### Q1: API Key 无效？

**原因**:
- Key 格式错误
- Key 已过期
- Key 被撤销

**解决**:
1. 检查 Key 格式（`sk-or-v1-...`）
2. 在 OpenRouter 后台重新生成
3. 确认 Key 状态为 "Active"

### Q2: 请求超时？

**原因**:
- 网络问题
- 速率限制
- 模型繁忙

**解决**:
1. 增加超时时间（30-60秒）
2. 添加重试逻辑
3. 降低请求频率

### Q3: 模型不可用？

**原因**:
- 模型已下线
- 模型维护中
- 地区限制

**解决**:
1. 查看可用模型列表
2. 切换到其他免费模型
3. 等待模型恢复

---

## 🔄 后续步骤

1. **获取 API Key** - 访问 https://openrouter.ai/keys
2. **配置到系统** - 添加到 `.env` 文件
3. **测试连接** - 运行测试脚本
4. **开始使用** - 在 Bounty 任务中应用

---

**配置指南完成！** 🌾

**下一步**: 请提供您的 OpenRouter API Key，我来帮您配置。
