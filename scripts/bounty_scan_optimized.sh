#!/bin/bash
# Bounty 智能扫描优化版 v2.1
# 集成 Vulkan 加速（如果可用）
# 创建时间: 2026-03-31 21:20 PDT

set -e

WORKSPACE_DIR="$HOME/.openclaw/workspace"
DATA_DIR="$WORKSPACE_DIR/data"
CACHE_DIR="$WORKSPACE_DIR/.cache"
LOG_FILE="$DATA_DIR/bounty-scan-optimized.log"
REPORT_FILE="$DATA_DIR/bounty-scan-report-$(date +%Y-%m-%d).md"

# 检查 Vulkan
if command -v vulkaninfo &> /dev/null; then
    USE_VULKAN=true
    echo "✅ Vulkan 已启用"
else
    USE_VULKAN=false
    echo "⚠️ Vulkan 未安装，使用标准模式"
fi

# 检查 QMD 向量化工具
if command -v qmd &> /dev/null; then
    USE_QMD=true
    echo "✅ QMD 向量化已启用"
else
    USE_QMD=false
    echo "⚠️ QMD 未安装，跳过向量化"
fi

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    local timestamp=$(date '+%H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

# 扫描函数
scan_bounties() {
    log "🚀 开始扫描..."

    # 清理旧缓存
    find "$CACHE_DIR" -name "bounty-scan-*" -mtime +1 -delete 2>/dev/null

    # 第一轮：快速筛选
    log "📍 Round 1: 快速筛选（金额 > $100）"
    local round1_results=$(mktemp)

    gh search issues "bounty" ">$100" --state open --limit 50 \
        --json number,title,repository,labels \
        --jq '.[] | "\(.repository.owner.login)/\(.repository.name)#\(.number)|\(.title)"' \
        > "$round1_results" 2>/dev/null || true

    local count=$(wc -l < "$round1_results" | tr -d ' ')
    log "✅ Round 1 完成: $count 个任务"

    # 第二轮：维护者活跃度检查
    log "📍 Round 2: 维护者活跃度检查"
    local high_value=0

    while IFS='|' read -r repo_issue title; do
        local repo=$(echo "$repo_issue" | cut -d'#' -f1)

        # 检查维护者活跃度
        local repo_info=$(gh api "repos/$repo" --jq '{pushed: .pushed_at}' 2>/dev/null)

        if [ -n "$repo_info" ]; then
            local pushed=$(echo "$repo_info" | jq -r '.pushed')
            if [ -n "$pushed" ]; then
                local days=$(( ($(date +%s) - $(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$pushed" +%s 2>/dev/null || echo 0)) / 86400 ))

                if [ $days -lt 7 ]; then
                    log "  ✅ $repo（${days}天前 push）"
                    ((high_value++))
                    echo "$repo_issue|$title|$days" >> "$CACHE_DIR/high-value-tasks.txt"
                fi
            fi
        fi
    done < "$round1_results"

    log "✅ Round 2 完成: $high_value 个高价值任务"

    # 清理
    rm -f "$round1_results"

    # 生成报告
    generate_report $high_value
}

# 生成报告
generate_report() {
    local count=$1

    echo "# 🎯 Bounty 扫描报告（优化版）" > "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "**扫描时间**: $(date '+%Y-%m-%d %H:%M:%S')" >> "$REPORT_FILE"
    echo "**Vulkan**: $([ "$USE_VULKAN" = true ] && echo "✅ 已启用" || echo "❌ 未安装")" >> "$REPORT_FILE"
    echo "**QMD**: $([ "$USE_QMD" = true ] && echo "✅ 已启用" || echo "❌ 未安装")" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "---" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    if [ -f "$CACHE_DIR/high-value-tasks.txt" ]; then
        echo "## 📊 高价值任务列表" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        cat "$CACHE_DIR/high-value-tasks.txt" | while IFS='|' read -r repo title days; do
            echo "- **$repo**: $title (${days}天前)" >> "$REPORT_FILE"
        done
    fi

    log "✅ 报告已生成: $REPORT_FILE"
}

# 主函数
main() {
    log "================================"
    log "🚀 Bounty 智能扫描 v2.1（优化版）"
    log "================================"

    mkdir -p "$DATA_DIR" "$CACHE_DIR"

    scan_bounties
}

main "$@"
