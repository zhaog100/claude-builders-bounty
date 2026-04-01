#!/bin/bash
# Bounty 智能扫描 v2.0 - 基于质量评估标准
# 创建时间: 2026-03-31 20:05 PDT

set -e

# 配置
WORKSPACE_DIR="$HOME/.openclaw/workspace"
DATA_DIR="$WORKSPACE_DIR/data"
LOG_FILE="$DATA_DIR/bounty-scan-v2.log"
RESULTS_FILE="$DATA_DIR/bounty-scan-results-v2.md"
BLACKLIST_FILE="$DATA_DIR/bounty-known-issues.txt"
REPO_BLACKLIST="$DATA_DIR/bounty-repo-blacklist.txt"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 检查依赖
check_dependencies() {
    if ! command -v gh &> /dev/null; then
        log "${RED}错误: 未安装 gh 命令${NC}"
        exit 1
    fi
    if ! command -v jq &> /dev/null; then
        log "${YELLOW}警告: 未安装 jq，评分功能受限${NC}"
    fi
}

# 评估单个 bounty
evaluate_bounty() {
    local owner_repo="$1"
    local issue_number="$2"
    local amount="$3"
    local title="$4"
    local labels="$5"
    local comments="$6"
    
    local score=0
    local details=""
    
    # 1. 检查维护者活跃度（40 分）
    log "${BLUE}检查维护者活跃度...${NC}"
    
    local maintainer_activity_score=0
    local repo_info=$(gh api "repos/$owner_repo" --jq '{pushed: .pushed_at, stars: .stargazers_count, updated: .updated_at}')
    local last_push=$(echo "$repo_info" | jq -r '.pushed')
    
    if [ -n "$last_push" ]; then
        local days_since_push=$(( ($(date +%s) - $(date -j "%Y-%m-%dT%H:%M:%SZ" "$last_push" +%s)) / 86400 ))
        
        if [ $days_since_push -lt 3 ]; then
            maintainer_activity_score=40
            details+="✅ 维护者活跃（${days_since_push}天前 push）\n"
        elif [ $days_since_push -lt 7 ]; then
            maintainer_activity_score=30
            details+="⚠️ 维护者较活跃（${days_since_push}天前 push）\n"
        elif [ $days_since_push -lt 14 ]; then
            maintainer_activity_score=10
            details+="⚠️ 维护者不活跃（${days_since_push}天前 push）\n"
        else
            maintainer_activity_score=0
            details+="❌ 维护者跑路（${days_since_push}天前 push）\n"
        fi
    fi
    
    score+=$maintainer_activity_score
    
    # 2. 金额与工作量匹配（25 分）
    local amount_match_score=0
    if [ -n "$amount" ]; then
        amount=$(echo "$amount" | grep -oE '[0-9]+')
        if [ $amount -ge 200 ] && [ $amount -le 500 ]; then
            amount_match_score=25
            details+="✅ 金额适中（\$$amount）\n"
        elif [ $amount -ge 100 ] && [ $amount -lt 200 ]; then
            amount_match_score=20
            details+="✅ 金额可接受（\$$amount）\n"
        elif [ $amount -ge 50 ] && [ $amount -lt 100 ]; then
            amount_match_score=15
            details+="⚠️ 金额偏低（\$$amount）\n"
        elif [ $amount -gt 500 ]; then
            amount_match_score=10
            details+="⚠️ 金额过高需评估（\$$amount）\n"
        else
            amount_match_score=0
            details+="❌ 金额太低（\$$amount）\n"
        fi
    else
        amount_match_score=10
        details+="⚠️ 未标注金额\n"
    fi
    
    score+=$amount_match_score
    
    # 3. 竞争度（20 分）
    local competition_score=0
    if [ -n "$comments" ]; then
        comments=$(echo "$comments" | grep -oE '[0-9]+')
        if [ $comments -lt 5 ]; then
            competition_score=20
            details+="✅ 低竞争（${comments} 评论）\n"
        elif [ $comments -lt 10 ]; then
            competition_score=15
            details+="✅ 中等竞争（${comments} 评论）\n"
        elif [ $comments -lt 20 ]; then
            competition_score=10
            details+="⚠️ 高竞争（${comments} 评论）\n"
        else
            competition_score=5
            details+="❌ 竞争激烈（${comments} 评论）\n"
        fi
    else
        competition_score=15
        details+="✅ 无评论\n"
    fi
    
    score+=$competition_score
    
    # 4. 标签匹配（加分项）
    if echo "$labels" | grep -qi "security"; then
        score+=5
        details+="✅ Security 标签（+5 分）\n"
    fi
    if echo "$labels" | grep -qi "bounty"; then
        score+=3
        details+="✅ Bounty 标签（+3 分）\n"
    fi
    
    # 5. 评级
    local grade=""
    if [ $score -ge 90 ]; then
        grade="S"
        priority="🚀 立即执行"
    elif [ $score -ge 70 ]; then
        grade="A"
        priority="✅ 优先处理"
    elif [ $score -ge 50 ]; then
        grade="B"
        priority="⚠️ 考虑执行"
    elif [ $score -ge 30 ]; then
        grade="C"
        priority="🤔 慎重考虑"
    else
        grade="D"
        priority="❌ 放弃"
    fi
    
    # 输出结果
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "${BLUE}仓库:${NC} $owner_repo"
    echo "${BLUE}Issue:${NC} #$issue_number - $title"
    echo "${BLUE}金额:${NC} \$$amount"
    echo ""
    echo "${BLUE}📊 评分明细:${NC}"
    echo "  维护者活跃度: $maintainer_activity_score/40"
    echo "  金额匹配度: $amount_match_score/25"
    echo "  竞争度: $competition_score/20"
    echo ""
    echo "${BLUE}总分:${NC} $score/100 ${YELLOW}($grade 级)${NC}"
    echo "${BLUE}决策:${NC} $priority"
    echo ""
    echo -e "$details"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # 返回 JSON（用于管道处理）
    if [ "$JSON_OUTPUT" = "true" ]; then
        cat <<EOF
{
  "repo": "$owner_repo",
  "issue": $issue_number,
  "title": "$title",
  "amount": $amount,
  "score": $score,
  "grade": "$grade",
  "priority": "$priority",
  "details": "$(echo "$details" | tr '\n' ' ')"
}
EOF
    fi
}

# 扫描 bounties
scan_bounties() {
    log "${GREEN}=== 开始扫描 Bounty ===${NC}"
    
    # 搜索关键词
    local queries=(
        "bounty \$50 state:open no:assignee"
        "bounty \$100 state:open no:assignee"
        "bounty \$200 state:open no:assignee"
        "bounty \$300 state:open no:assignee"
        "bounty \$500 state:open no:assignee"
        "label:bounty state:open no:assignee"
        "label:security state:open bounty"
    )
    
    local all_results=()
    
    for query in "${queries[@]}"; do
        log "${BLUE}搜索: $query${NC}"
        
        local results=$(gh search issues "$query" --limit 50 --json number,title,repository,labels,comments --jq '.[] | "\(.repository.owner.login)/\(.repository.name)|\(.number)|\(.title)|\(.labels[].name)|\(.comments)"' 2>/dev/null)
        
        if [ -n "$results" ]; then
            while IFS='|' read -r repo issue title labels comments; do
                # 检查黑名单
                if grep -q "$repo" "$REPO_BLACKLIST" 2>/dev/null; then
                    log "${YELLOW}跳过黑名单仓库: $repo${NC}"
                    continue
                fi
                
                # 提取金额
                local amount=$(echo "$title" | grep -oE '\$[0-9]+' | head -1 | tr -d '$')
                
                all_results+=("$repo|$issue|$title|$amount|$labels|$comments")
            done <<< "$results"
        fi
        
        sleep 2
    done
    
    # 去重
    local unique_results=$(echo "${all_results[@]}" | sort -u)
    
    # 评估每个 bounty
    local count=0
    local high_score_count=0
    
    echo "" > "$RESULTS_FILE"
    echo "# 🎯 Bounty 扫描结果 v2.0" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    echo "**扫描时间**: $(date '+%Y-%m-%d %H:%M:%S')" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    echo "---" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    
    for result in $unique_results; do
        if [ -z "$result" ]; then
            continue
        fi
        
        IFS='|' read -r repo issue title amount labels comments <<< "$result"
        
        ((count++))
        
        log "${BLUE}[$count] 评估: $repo #$issue${NC}"
        
        # 评估并输出
        evaluate_bounty "$repo" "$issue" "$amount" "$title" "$labels" "$comments"
        
        # 只记录 B 级以上的任务
        if [ $score -ge 50 ]; then
            ((high_score_count++))
            echo "## $repo #$issue - \$$amount ($grade 级)" >> "$RESULTS_FILE"
            echo "" >> "$RESULTS_FILE"
            echo "- **评分**: $score/100" >> "$RESULTS_FILE"
            echo "- **决策**: $priority" >> "$RESULTS_FILE"
            echo "- **链接**: https://github.com/$repo/issues/$issue" >> "$RESULTS_FILE"
            echo "" >> "$RESULTS_FILE"
            echo "---" >> "$RESULTS_FILE"
            echo "" >> "$RESULTS_FILE"
        fi
    done
    
    log "${GREEN}=== 扫描完成 ===${NC}"
    log "总共扫描: $count 个 bounty"
    log "高价值任务（B 级以上）: $high_score_count 个"
    log "结果文件: $RESULTS_FILE"
}

# 主函数
main() {
    check_dependencies
    
    mkdir -p "$DATA_DIR"
    
    log "${GREEN}Bounty 智能扫描 v2.0${NC}"
    log "${GREEN}基于质量评估标准优化${NC}"
    
    scan_bounties
}

# 执行
main "$@"
