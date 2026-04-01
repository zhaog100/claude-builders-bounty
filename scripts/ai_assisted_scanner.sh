#!/bin/bash
# AI 辅助 Bounty 扫描器
# 创建时间: 2026-04-01 16:48 CST
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

# 配置文件
CONFIG_FILE="$WORKSPACE_DIR/.ai-scanner-config.json"
DEFAULT_CONFIG='{
  "api_provider": "openrouter",
  "model": "qwen/qwen3.6-plus-preview:free",
  "max_tokens": 4000,
  "temperature": 0.7,
  "enable_code_review": true,
  "enable_security_analysis": true,
  "enable_value_assessment": true,
  "cache_ai_responses": true,
  "cache_ttl_hours": 24
}'

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

# 初始化配置
init_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        log "${BLUE}创建默认配置文件...${NC}"
        echo "$DEFAULT_CONFIG" > "$CONFIG_FILE"
    fi

    # 读取配置 (使用 Python 替代 jq)
    ENABLE_CODE_REVIEW=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE'))['enable_code_review'])" 2>/dev/null || echo "true")
    ENABLE_SECURITY=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE'))['enable_security_analysis'])" 2>/dev/null || echo "true")
    ENABLE_VALUE=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE'))['enable_value_assessment'])" 2>/dev/null || echo "true")
    MAX_TOKENS=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE'))['max_tokens'])" 2>/dev/null || echo "4000")
    TEMPERATURE=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE'))['temperature'])" 2>/dev/null || echo "0.7")
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
    local cache_key=$(echo "$prompt" | shasum | cut -d' ' -f1)
    local cache_file="$CACHE_DIR/ai-cache-$cache_key.json"

    # 检查缓存
    if [ -f "$cache_file" ]; then
        local cache_age=$((($(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file")) / 3600))
        if [ $cache_age -lt 24 ]; then
            log "${BLUE}使用缓存响应...${NC}"
            cat "$cache_file"
            return 0
        fi
    fi

    # 调用 API
    log "${BLUE}调用 Qwen3.6 Plus API...${NC}"
    local response=$(curl -s -X POST "$OPENROUTER_API_URL" \
        -H "Authorization: Bearer $OPENROUTER_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"$MODEL\",
            \"messages\": [{\"role\": \"user\", \"content\": $(echo "$prompt" | jq -Rs .)}],
            \"max_tokens\": $MAX_TOKENS,
            \"temperature\": $TEMPERATURE
        }" 2>&1)

    # 检查错误 (使用 Python 替代 jq)
    if ! echo "$response" | python3 -c "import sys, json; d=json.load(sys.stdin); exit(0 if 'error' not in d else 1)" 2>/dev/null; then
        :  # 没有错误
    else
        log "${RED}API 调用失败${NC}"
        return 1
    fi

    # 提取响应 (使用 Python 替代 jq)
    local content=$(echo "$response" | python3 -c "import sys, json; print(json.load(sys.stdin)['choices'][0]['message']['content'])" 2>/dev/null)

    # 保存缓存
    mkdir -p "$CACHE_DIR"
    echo "$content" > "$cache_file"

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

# AI 代码审查
ai_code_review() {
    local code="$1"
    local file_path="$2"

    log "${BLUE}AI 审查代码: $file_path${NC}"

    local prompt="你是一个专业的代码审查专家。请审查以下代码：

文件: $file_path

代码:
\`\`\`
$code
\`\`\`

请从以下方面分析：
1. 代码质量（1-10分）
2. 潜在安全问题
3. 性能问题
4. 改进建议
5. 总体评价

请提供详细的分析和建议。"

    local response=$(call_ai "$prompt")
    echo "$response"
}

# AI 安全分析
ai_security_analysis() {
    local code="$1"
    local file_path="$2"

    log "${BLUE}AI 安全分析: $file_path${NC}"

    local prompt="你是一个专业的安全分析专家。请分析以下代码的安全问题：

文件: $file_path

代码:
\`\`\`
$code
\`\`\`

请识别以下安全问题：
1. SQL 注入风险
2. XSS 风险
3. 认证/授权问题
4. 敏感信息泄露
5. 其他安全漏洞

请提供详细的安全分析报告和修复建议。"

    local response=$(call_ai "$prompt")
    echo "$response"
}

# AI 生成报告
ai_generate_report() {
    local scan_results="$1"
    local output_file="$2"

    log "${BLUE}AI 生成扫描报告...${NC}"

    local prompt="你是一个专业的技术文档撰写专家。基于以下扫描结果，生成一份专业的 bounty 任务报告：

扫描结果:
$scan_results

请生成包含以下内容的报告：
1. 执行摘要
2. 高价值任务列表（按评分排序）
3. 每个任务的详细分析
4. 推荐处理顺序
5. 预期收益

请使用 Markdown 格式。"

    local response=$(call_ai "$prompt")

    # 保存报告
    echo "$response" > "$output_file"
    log "${GREEN}报告已生成: $output_file${NC}"
}

# 集成到 bounty 扫描器
integrate_with_scanner() {
    local scanner_results="$1"

    log "${BLUE}集成 AI 分析到扫描结果...${NC}"

    # 对每个高价值任务进行 AI 分析
    echo "$scanner_results" | jq -c '.[]' | while read -r task; do
        local repo=$(echo "$task" | jq -r '.repository_url' | sed 's|.*/||')
        local number=$(echo "$task" | jq -r '.number')
        local title=$(echo "$task" | jq -r '.title')
        local body=$(echo "$task" | jq -r '.body')

        # AI 评估任务价值
        local assessment=$(assess_task_value "$repo" "$number" "$title" "$body")

        # 添加评估结果到任务
        echo "$task" | jq --argjson assessment "$assessment" '. + {ai_assessment: $assessment}'
    done
}

# 显示帮助
show_help() {
    cat << EOF
AI 辅助 Bounty 扫描器 v1.0

用法:
  $0 <command> [options]

命令:
  assess <repo> <issue_number> [title] [body]   评估单个任务价值
  review <file>                                  AI 代码审查
  security <file>                                AI 安全分析
  report <results_file> <output_file>           生成报告
  integrate <scanner_results>                    集成到扫描器
  config                                         显示配置
  help                                           显示帮助

环境变量:
  OPENROUTER_API_KEY     OpenRouter API Key（必需）

示例:
  # 评估任务价值
  $0 assess BerriAI/litellm 24530 "Security issue" "Details..."

  # 代码审查
  $0 review litellm/proxy/proxy_server.py

  # 安全分析
  $0 security litellm/proxy/proxy_server.py

  # 生成报告
  $0 report data/scan-results.json data/ai-report.md

  # 集成到扫描器
  cat data/scan-results.json | $0 integrate

EOF
}

# 主函数
main() {
    local command="${1:-help}"
    shift || true

    # 初始化
    init_config

    case "$command" in
        assess)
            check_api_key || exit 1
            local repo="$1"
            local number="$2"
            local title="${3:-}"
            local body="${4:-}"
            assess_task_value "$repo" "$number" "$title" "$body"
            ;;
        review)
            check_api_key || exit 1
            local file="$1"
            if [ ! -f "$file" ]; then
                log "${RED}错误: 文件不存在: $file${NC}"
                exit 1
            fi
            local code=$(cat "$file")
            ai_code_review "$code" "$file"
            ;;
        security)
            check_api_key || exit 1
            local file="$1"
            if [ ! -f "$file" ]; then
                log "${RED}错误: 文件不存在: $file${NC}"
                exit 1
            fi
            local code=$(cat "$file")
            ai_security_analysis "$code" "$file"
            ;;
        report)
            check_api_key || exit 1
            local results_file="$1"
            local output_file="$2"
            if [ ! -f "$results_file" ]; then
                log "${RED}错误: 结果文件不存在: $results_file${NC}"
                exit 1
            fi
            local results=$(cat "$results_file")
            ai_generate_report "$results" "$output_file"
            ;;
        integrate)
            check_api_key || exit 1
            local scanner_results=$(cat)
            integrate_with_scanner "$scanner_results"
            ;;
        config)
            cat "$CONFIG_FILE" | jq '.'
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
