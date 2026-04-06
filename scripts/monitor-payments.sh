#!/bin/bash
# 持续监控脚本 - 检查付款和 PR 状态
# 运行频率：每 6 小时（通过 cron 或 heartbeat）

echo "🔍 [$(date '+%Y-%m-%d %H:%M:%S')] 开始监控..."
echo ""

# 1. 检查 RustChain 付款状态
echo "📋 检查 RustChain #2755 付款状态..."
ISSUE_STATUS=$(gh issue view 2755 --repo Scottcjn/rustchain-bounties --json state,comments --jq '{state: .state, latest_comment: .comments[-1].createdAt}' 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "$ISSUE_STATUS" | jq -r '"  状态: \(.state)\n  最新评论: \(.latest_comment)"'
else
    echo "  ❌ 无法获取 Issue 状态"
fi
echo ""

# 2. 检查开放 PR 状态
echo "📋 检查开放 PR 状态..."
PRS=(
    "illbnm/homelab-stack:398:\$150"
    "illbnm/homelab-stack:401:\$130"
    "Kozea/pygal:579:\$300"
    "vllm-project/vllm-omni:2080:\$0"
)

for pr_info in "${PRS[@]}"; do
    IFS=':' read -r repo pr amount <<< "$pr_info"
    PR_STATUS=$(gh pr view "$pr" --repo "$repo" --json state,reviewDecision,mergeable 2>/dev/null)

    if [ $? -eq 0 ]; then
        echo "$repo#$pr ($amount):"
        echo "$PR_STATUS" | jq -r '"  \(.state) | \(.reviewDecision // "PENDING") | \(.mergeable)"'
    else
        echo "$repo#$pr ($amount): ❌ 无法获取"
    fi
done
echo ""

# 3. 检查 RustChain #2819 审核状态
echo "📋 检查 RustChain #2819 审核状态..."
AUDIT_STATUS=$(gh issue view 2819 --repo Scottcjn/rustchain-bounties --json state,comments --jq '{state: .state, comment_count: (.comments | length)}' 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "$AUDIT_STATUS" | jq -r '"  状态: \(.state)\n  评论数: \(.comment_count)"'
else
    echo "  ❌ 无法获取 Issue 状态"
fi
echo ""

# 4. 总结
echo "📊 监控完成"
echo "  待收款: \$580 USDT + 302 RTC"
echo "  下次检查: 6 小时后"
echo ""

# 5. 记录到日志
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 监控完成" >> ~/.openclaw/workspace/data/payment-monitor.log
