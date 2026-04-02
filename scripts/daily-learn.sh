#!/bin/bash
# 每日学习任务 - 18:00 执行

WORKSPACE=~/.openclaw/workspace
MEMORY_FILE="$WORKSPACE/memory/$(date +%Y-%m-%d).md"

echo "=== 📚 每日学习 ($(date '+%Y-%m-%d %H:%M')) ===" >> "$MEMORY_FILE"
echo "" >> "$MEMORY_FILE"
echo "## 🎓 今日学习" >> "$MEMORY_FILE"
echo "" >> "$MEMORY_FILE"

# 学习主题（每周轮换）
WEEKDAY=$(date +%u)
case $WEEKDAY in
  1) TOPIC="AI 编程工具" ;;
  2) TOPIC="安全漏洞挖掘" ;;
  3) TOPIC="开源项目趋势" ;;
  4) TOPIC="区块链/Web3" ;;
  5) TOPIC="DevOps 工具" ;;
  6) TOPIC="前端新技术" ;;
  7) TOPIC="系统优化" ;;
esac

echo "**主题**: $TOPIC" >> "$MEMORY_FILE"
echo "" >> "$MEMORY_FILE"
echo "**学到的 3 个新知识点**:" >> "$MEMORY_FILE"
echo "1. _待补充_" >> "$MEMORY_FILE"
echo "2. _待补充_" >> "$MEMORY_FILE"
echo "3. _待补充_" >> "$MEMORY_FILE"
echo "" >> "$MEMORY_FILE"

echo "✅ 每日学习任务已记录到 $MEMORY_FILE"
