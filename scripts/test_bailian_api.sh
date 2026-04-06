#!/bin/bash
# 百炼 API 测试脚本
# 测试 qwen3.5-plus 模型

# 加载环境变量
source ~/.openclaw/workspace/.env

echo "🔍 百炼 API 连接测试"
echo "━━━━━━━━━━━━━━━━━━━━"
echo "端点: https://coding.dashscope.aliyuncs.com/v1"
echo "模型: qwen3.5-plus"
echo ""

# 发送测试请求
RESPONSE=$(curl -s -X POST "https://coding.dashscope.aliyuncs.com/v1/chat/completions" \
  -H "Authorization: Bearer $BAILIAN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen3.5-plus",
    "messages": [
      {
        "role": "user",
        "content": "你好"
      }
    ]
  }')

# 检查响应
if echo "$RESPONSE" | grep -q '"error"'; then
  echo "❌ API 调用失败"
  echo "$RESPONSE" | jq -r '.error.message'
else
  echo "✅ API 连接成功"
  echo ""
  echo "📝 响应内容:"
  echo "$RESPONSE" | jq -r '.choices[0].message.content'
  echo ""
  echo "📊 Token 使用:"
  echo "  - Prompt: $(echo "$RESPONSE" | jq -r '.usage.prompt_tokens')"
  echo "  - Completion: $(echo "$RESPONSE" | jq -r '.usage.completion_tokens')"
  echo "  - Total: $(echo "$RESPONSE" | jq -r '.usage.total_tokens')"
fi
