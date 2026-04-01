#!/bin/bash
# Bounty 自动化扫描脚本
# 创建时间: 2026-04-01 16:25 CST
# 用途: 定期自动扫描 bounty 任务并发送通知

set -e

WORKSPACE_DIR="$HOME/.openclaw/workspace"
DATA_DIR="$WORKSPACE_DIR/data"
LOG_DIR="$WORKSPACE_DIR/logs/bounty"

# 配置
REPO_LIST_FILE="$DATA_DIR/bounty-repo-list.txt"
REPORT_FILE="$DATA_DIR/bounty-auto-scan-report-$(date +%Y-%m-%d).md"
LOG_FILE="$LOG_DIR/auto-scan-$(date +%Y-%m-%d).log"

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# 日志函数
log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "[$timestamp] $1" | tee -a "$LOG_FILE"
}

# 初始化
init() {
    mkdir -p "$LOG_DIR"

    # 创建仓库列表（如果不存在）
    if [ ! -f "$REPO_LIST_FILE" ]; then
        log "${YELLOW}创建默认仓库列表...${NC}"
        cat > "$REPO_LIST_FILE" << EOF
BerriAI/litellm
illbnm/homelab-stack
Scottcjn/rustchain-bounties
OpenCLaw/openclaw
python/cpython
EOF
    fi
}

# 执行扫描
scan() {
    log "${BLUE}开始自动扫描...${NC}"

    # 调用统一扫描器
    "$WORKSPACE_DIR/scripts/bounty_unified_scanner.sh" batch "$REPO_LIST_FILE" >> "$LOG_FILE" 2>&1

    if [ $? -eq 0 ]; then
        log "${GREEN}扫描完成${NC}"
    else
        log "${RED}扫描失败${NC}"
        return 1
    fi
}

# 发送通知（可选）
notify() {
    local report_file="$1"

    if [ ! -f "$report_file" ]; then
        log "${YELLOW}未找到报告文件，跳过通知${NC}"
        return 0
    fi

    # 提取高价值任务数量
    local high_value_count=$(grep -c "### \[" "$report_file" 2>/dev/null || echo 0)

    log "${GREEN}发现 $high_value_count 个高价值任务${NC}"

    # TODO: 集成通知系统（如 QQ、邮件、Slack 等）
    # 示例: 发送到 QQ
    # if [ $high_value_count -gt 0 ]; then
    #     "$WORKSPACE_DIR/scripts/notify.sh" "发现 $high_value_count 个高价值 bounty 任务！"
    # fi
}

# 主函数
main() {
    init
    scan
    notify "$REPORT_FILE"
}

# 执行
main "$@"
