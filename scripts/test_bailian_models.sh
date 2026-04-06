#!/bin/bash
# 百炼 API 多模型测试脚本
# 测试所有可用模型

# 加载环境变量
source ~/.openclaw/workspace/.env

echo "🔍 百炼 API 多模型测试"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "端点: https://coding.dashscope.aliyuncs.com/v1"
echo ""

# 模型列表
MODELS=(
  "qwen3.5-plus"
  "qwen3-max-2026-01-23"
  "qwen3-coder-next"
  "qwen3-coder-plus"
  "glm-5"
  "glm-4.7"
  "kimi-k2.5"
  "MiniMax-M2.5"
)

# 测试提示
TEST_PROMPT="你好，请用一句话介绍你自己。"

# 测试每个模型
for MODEL in "${MODELS[@]}"; do
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📦 测试模型: $MODEL"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # 发送测试请求
  RESPONSE=$(curl -s -X POST "https://coding.dashscope.aliyuncs.com/v1/chat/completions" \
    -H "Authorization: Bearer $BAILIAN_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{
      \"model\": \"$MODEL\",
      \"messages\": [
        {
          \"role\": \"user\",
          \"content\": \"$TEST_PROMPT\"
        }
      ]
    }")

  # 检查响应
  if echo "$RESPONSE" | grep -q '"error"'; then
    echo "❌ 测试失败"
    echo "   错误: $(echo "$RESPONSE" | jq -r '.error.message')"
  else
    echo "✅ 测试成功"
    echo "   响应: $(echo "$RESPONSE" | jq -r '.choices[0].message.content' | head -c 100)..."
    echo "   Token: $(echo "$RESPONSE" | jq -r '.usage.total_tokens')"
  fi

  echo ""

  # 避免频率限制
  sleep 1
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 测试完成"
