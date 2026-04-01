#!/bin/bash
# Bounty 统一扫描系统 v1.0
# 创建时间: 2026-04-01 16:15 CST
# 用途: 统一所有 bounty 扫描功能，提供一站式扫描服务

set -e

WORKSPACE_DIR="$HOME/.openclaw/workspace"
DATA_DIR="$WORKSPACE_DIR/data"
CACHE_DIR="$WORKSPACE_DIR/.cache"
KNOWLEDGE_DIR="$WORKSPACE_DIR/knowledge/bounty"
LOG_DIR="$WORKSPACE_DIR/logs/bounty"

# 配置
CONFIG_FILE="$WORKSPACE_DIR/.bounty-scanner-config.json"
DEFAULT_CONFIG='{
  "min_score": 70,
  "max_repos_per_scan": 50,
  "cache_ttl_hours": 24,
  "parallel_jobs": 3,
  "timeout_seconds": 300,
  "enabled_categories": ["security", "feature", "bug", "documentation"],
  "priority_order": ["security", "feature", "bug", "documentation"],
  "blacklist_repos": [],
  "blacklist_issues": []
}'

# 日志
LOG_FILE="$LOG_DIR/scan-$(date +%Y-%m-%d_%H%M%S).log"
mkdir -p "$LOG_DIR"

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# 日志函数
log() {
    local timestamp=$(date '+%H:%M:%S')
    echo -e "[$timestamp] $1" | tee -a "$LOG_FILE"
}

# 初始化配置
init_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        log "${BLUE}创建默认配置文件...${NC}"
        echo "$DEFAULT_CONFIG" > "$CONFIG_FILE"
    fi

    # 读取配置
    MIN_SCORE=$(jq -r '.min_score' "$CONFIG_FILE")
    MAX_REPOS=$(jq -r '.max_repos_per_scan' "$CONFIG_FILE")
    CACHE_TTL=$(jq -r '.cache_ttl_hours' "$CONFIG_FILE")
    PARALLEL_JOBS=$(jq -r '.parallel_jobs' "$CONFIG_FILE")
    TIMEOUT=$(jq -r '.timeout_seconds' "$CONFIG_FILE")
}

# 初始化缓存
init_cache() {
    mkdir -p "$CACHE_DIR"
    local today=$(date +%Y-%m-%d)
    CACHE_FILE="$CACHE_DIR/bounty-scan-$today.json"

    if [ ! -f "$CACHE_FILE" ]; then
        log "${BLUE}创建新的缓存文件...${NC}"
        echo '{"scanned_at": "'$(date -Iseconds)'", "repos": []}' > "$CACHE_FILE"
    fi
}

# 检查黑名单
check_blacklist() {
    local repo="$1"
    local issue_number="$2"

    # 检查仓库黑名单
    if jq -e ".blacklist_repos | index(\"$repo\")" "$CONFIG_FILE" > /dev/null 2>&1; then
        return 1
    fi

    # 检查 issue 黑名单
    local issue_id="${repo}#${issue_number}"
    if jq -e ".blacklist_issues | index(\"$issue_id\")" "$CONFIG_FILE" > /dev/null 2>&1; then
        return 1
    fi

    return 0
}

# 计算任务评分
calculate_score() {
    local repo="$1"
    local issue_number="$2"
    local labels="$3"
    local comments="$4"

    local score=0

    # 标签权重
    if echo "$labels" | grep -qi "security\|bounty\|bug-bounty"; then
        score=$((score + 40))
    fi
    if echo "$labels" | grep -qi "help wanted\|good first issue"; then
        score=$((score + 20))
    fi
    if echo "$labels" | grep -qi "high priority\|urgent"; then
        score=$((score + 15))
    fi

    # 活跃度（基于评论数）
    if [ "$comments" -gt 10 ]; then
        score=$((score + 10))
    elif [ "$comments" -gt 5 ]; then
        score=$((score + 5))
    fi

    echo "$score"
}

# 扫描单个仓库
scan_repo() {
    local repo="$1"
    local max_issues="${2:-10}"

    log "${BLUE}扫描仓库: $repo${NC}"

    # 使用 GitHub API 搜索 issues
    local issues_json=$(gh api "repos/$repo/issues" \
        --paginate \
        -H "Accept: application/vnd.github.v3+json" \
        -f state=open \
        -f per_page=100 \
        --jq '.[] | select(.labels[].name | test("bounty|security|bug-bounty|help wanted"; "i"))' \
        2>/dev/null || echo '[]')

    if [ "$issues_json" = '[]' ]; then
        log "${YELLOW}未找到符合条件的 issues${NC}"
        return 0
    fi

    local count=0
    while IFS= read -r issue; do
        [ -z "$issue" ] && continue
        [ $count -ge $max_issues ] && break

        local number=$(echo "$issue" | jq -r '.number')
        local title=$(echo "$issue" | jq -r '.title')
        local labels=$(echo "$issue" | jq -r '.labels[].name' | tr '\n' ',')
        local comments=$(echo "$issue" | jq -r '.comments')

        # 检查黑名单
        if ! check_blacklist "$repo" "$number"; then
            log "${YELLOW}跳过黑名单中的 issue #$number${NC}"
            continue
        fi

        # 计算评分
        local score=$(calculate_score "$repo" "$number" "$labels" "$comments")

        # 检查最低分数
        if [ "$score" -lt "$MIN_SCORE" ]; then
            continue
        fi

        # 输出结果
        log "${GREEN}✓ 找到高价值 issue #$number (评分: $score)${NC}"
        echo "$issue" | jq --argjson score "$score" '. + {score: $score}'

        count=$((count + 1))
    done <<< "$(echo "$issues_json" | jq -c '.')"

    return 0
}

# 批量扫描
batch_scan() {
    local repos_file="$1"

    if [ ! -f "$repos_file" ]; then
        log "${RED}错误: 仓库列表文件不存在: $repos_file${NC}"
        return 1
    fi

    log "${BLUE}开始批量扫描...${NC}"
    log "${BLUE}配置: 最低评分=$MIN_SCORE, 最大仓库数=$MAX_REPOS, 并行数=$PARALLEL_JOBS${NC}"

    local total_repos=$(wc -l < "$repos_file")
    local scanned=0
    local found=0

    # 创建临时文件存储结果
    local results_file=$(mktemp)

    while IFS= read -r repo; do
        [ -z "$repo" ] && continue
        [ $scanned -ge $MAX_REPOS ] && break

        # 扫描仓库
        scan_repo "$repo" 5 >> "$results_file" &
        local pid=$!

        # 控制并行数
        if [ $((scanned % PARALLEL_JOBS)) -eq 0 ]; then
            wait $pid 2>/dev/null || true
        fi

        scanned=$((scanned + 1))
    done < "$repos_file"

    # 等待所有后台任务完成
    wait

    # 统计结果
    found=$(jq -s 'length' "$results_file" 2>/dev/null || echo 0)

    log "${GREEN}扫描完成: $scanned/$total_repos 个仓库, 找到 $found 个高价值任务${NC}"

    # 保存到缓存
    if [ "$found" -gt 0 ]; then
        jq -s '.' "$results_file" > "$CACHE_FILE"
    fi

    # 生成报告
    generate_report "$results_file"

    rm -f "$results_file"
}

# 生成报告
generate_report() {
    local results_file="$1"
    local report_file="$DATA_DIR/bounty-scan-report-$(date +%Y-%m-%d).md"

    log "${BLUE}生成报告: $report_file${NC}"

    cat > "$report_file" << EOF
# Bounty 扫描报告

**扫描时间**: $(date '+%Y-%m-%d %H:%M:%S %Z')
**配置**:
- 最低评分: $MIN_SCORE
- 扫描仓库数: $scanned
- 发现任务数: $found

---

## 高价值任务

EOF

    # 按评分排序
    jq -s 'sort_by(.score) | reverse | .[]' "$results_file" 2>/dev/null | \
    while IFS= read -r issue; do
        local repo=$(echo "$issue" | jq -r '.repository_url' | sed 's|.*/||')
        local number=$(echo "$issue" | jq -r '.number')
        local title=$(echo "$issue" | jq -r '.title')
        local score=$(echo "$issue" | jq -r '.score')
        local url=$(echo "$issue" | jq -r '.html_url')

        cat >> "$report_file" << EOF

### [$title]($url)

- **仓库**: $repo
- **Issue**: #$number
- **评分**: $score
- **链接**: $url

EOF
    done

    log "${GREEN}报告已生成: $report_file${NC}"
}

# 显示帮助
show_help() {
    cat << EOF
Bounty 统一扫描系统 v1.0

用法:
  $0 <command> [options]

命令:
  scan <repo>              扫描单个仓库
  batch <repos_file>       批量扫描仓库列表
  config                   显示当前配置
  update-config            更新配置
  cache                    显示缓存状态
  clean                    清理缓存
  help                     显示此帮助信息

选项:
  --min-score <score>      设置最低评分阈值 (默认: 70)
  --max-repos <number>     设置最大扫描仓库数 (默认: 50)
  --parallel <number>      设置并行扫描数 (默认: 3)

示例:
  $0 scan BerriAI/litellm
  $0 batch data/repo-list.txt --min-score 80
  $0 config
  $0 update-config

EOF
}

# 主函数
main() {
    local command="${1:-help}"
    shift || true

    # 初始化
    init_config
    init_cache

    case "$command" in
        scan)
            local repo="$1"
            if [ -z "$repo" ]; then
                log "${RED}错误: 请指定仓库${NC}"
                exit 1
            fi
            scan_repo "$repo" "${2:-10}"
            ;;
        batch)
            local repos_file="$1"
            if [ -z "$repos_file" ]; then
                log "${RED}错误: 请指定仓库列表文件${NC}"
                exit 1
            fi
            batch_scan "$repos_file"
            ;;
        config)
            cat "$CONFIG_FILE" | jq '.'
            ;;
        update-config)
            ${EDITOR:-vi} "$CONFIG_FILE"
            ;;
        cache)
            if [ -f "$CACHE_FILE" ]; then
                log "${BLUE}缓存文件: $CACHE_FILE${NC}"
                jq '{scanned_at, repo_count: (.repos | length)}' "$CACHE_FILE"
            else
                log "${YELLOW}缓存为空${NC}"
            fi
            ;;
        clean)
            rm -f "$CACHE_DIR"/bounty-scan-*.json
            log "${GREEN}缓存已清理${NC}"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log "${RED}未知命令: $command${NC}"
            show_help
            exit 1
            ;;
    esac
}

# 执行
main "$@"
