#!/bin/bash
# AI 辅助 Bounty 扫描器 v2.0 (无 jq 依赖)
# 创建时间: 2026-04-01 17:25 CST
# 用途: 集成 OpenRouter API (Qwen3.6 Plus) 进行智能分析

set -e

WORKSPACE_DIR="$HOME/.openclaw/workspace"
DATA_DIR="$WORKSPACE_DIR/data"
CACHE_DIR="$WORKSPACE_DIR/.cache"
LOG_DIR="$WORKSPACE_DIR/logs/bounty"

# OpenRouter API 配置
OPENROUTER_API_KEY="${OPENROUTER_API_KEY:-}"
OPENROUTER_API_URL="https://openrouter.ai/api/v1/chat/completions"
MODEL="qwen/qwen3.6-plus-preview:free"

# 日志
LOG_FILE="$LOG_DIR/ai-scanner-$(date +%Y-%m-%d).log"
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

# 检查 API Key
check_api_key() {
    if [ -z "$OPENROUTER_API_KEY" ]; then
        log "${RED}错误: 未设置 OPENROUTER_API_KEY${NC}"
        log "${YELLOW}请访问 https://openrouter.ai/keys 获取 API Key${NC}"
        log "${YELLOW}然后设置环境变量: export OPENROUTER_API_KEY='your_key'${NC}"
        return 1
    fi
    return 0
}

# 调用 AI API
call_ai() {
    local prompt="$1"
    
    log "${BLUE}调用 Qwen3.6 Plus API...${NC}"
    
    local response=$(curl -s -X POST "$OPENROUTER_API_URL" \
        -H "Authorization: Bearer $OPENROUTER_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"$MODEL\",
            \"messages\": [{\"role\": \"user\", \"content\": $(echo "$prompt" | python3 -c "import sys, json; print(json.dumps(sys.stdin.read()))")}]
        }" 2>&1)
    
    # 检查响应是否成功
    if echo "$response" | python3 -c "import sys, json; d=json.load(sys.stdin); exit(0 if 'id' in d else 1)" 2>/dev/null; then
        :  # 成功
    else
        log "${RED}API 调用失败${NC}"
        echo "$response" | python3 -c "import sys, json; print(json.load(sys.stdin).get('error', {}).get('message', 'Unknown error')" >&2
        return 1
    fi
    
    # 提取响应 (使用 Python)
    local content=$(echo "$response" | python3 -c "import sys, json; print(json.load(sys.stdin)['choices'][0]['message']['content'])" 2>/dev/null)
    
    echo "$content"
}

# AI 评估任务价值
assess_task_value() {
    local repo="$1"
    local issue_number="$2"
    local issue_title="$3"
    local issue_body="$4"
    
    log "${BLUE}AI 评估任务价值: $repo#$issue_number${NC}"
    
    local prompt="你是一个专业的 bounty 任务评估专家。请分析以下 GitHub issue 的价值：

仓库: $repo
Issue: #$issue_number
标题: $issue_title

内容:
$issue_body

请从以下维度评估（1-10分）：
1. 技术难度
2. 市场价值
3. 学习价值
4. 完成时间估计
5. 总体评分

请以 JSON 格式返回评估结果。"
    
    local response=$(call_ai "$prompt")
    echo "$response"
}

# 显示帮助
show_help() {
    cat << EOF
AI 辅助 Bounty 扫描器 v2.0

用法:
  $0 assess <repo> <issue_number> [title] [body]   评估任务价值
  help                                           显示帮助

环境变量:
  OPENROUTER_API_KEY     OpenRouter API Key（必需）

示例:
  # 评估任务价值
  $0 assess BerriAI/litellm 24530 "Security issue" "Details..."

EOF
}

# 主函数
main() {
    local command="${1:-help}"
    shift || true
    
    case "$command" in
        assess)
            check_api_key || exit 1
            local repo="$1"
            local number="$2"
            local title="${3:-}"
            local body="${4:-}"
            assess_task_value "$repo" "$number" "$title" "$body"
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
