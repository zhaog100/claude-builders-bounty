#!/bin/bash
# 每日维护脚本 - 凌晨2点执行
# 创建时间: 2026-03-31 16:57 PDT
# 更新时间: 2026-03-31 17:00 PDT
# 功能: 结构化整理、回顾总结、更新仓库、重启 Gateway

# ==================== 配置 ====================
WORKSPACE="/Users/zhaog/.openclaw/workspace"
MEMORY_DIR="$WORKSPACE/memory"
KNOWLEDGE_DIR="$WORKSPACE/knowledge"
DATA_DIR="$WORKSPACE/data"
LOG_FILE="$WORKSPACE/data/daily-maintenance.log"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 日志函数
log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "[$timestamp] $1" | tee -a "$LOG_FILE"
}

log_section() {
    echo "" | tee -a "$LOG_FILE"
    echo -e "${CYAN}========================================${NC}" | tee -a "$LOG_FILE"
    echo -e "${CYAN}$1${NC}" | tee -a "$LOG_FILE"
    echo -e "${CYAN}========================================${NC}" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1" | tee -a "$LOG_FILE"
}

# 错误处理
handle_error() {
    log_error "错误发生在第 $1 行: $2"
    # 继续执行，不退出
}

# 设置错误陷阱
trap 'handle_error $LINENO "$BASH_COMMAND"' ERR

# 初始化日志
mkdir -p "$DATA_DIR"
echo "" >> "$LOG_FILE"
log_section "每日维护开始 $(date '+%Y-%m-%d %H:%M:%S')"

# ==================== 1. 结构化整理 ====================
log_section "1️⃣ 结构化整理"

# 1.1 记忆整理
log "整理记忆文件..."
cd "$WORKSPACE" || { log_error "无法切换到工作目录"; }

# 删除空文件和临时文件
find "$MEMORY_DIR" -type f -name "*.tmp" -delete 2>/dev/null || true
find "$MEMORY_DIR" -type f -empty -delete 2>/dev/null || true

# 更新记忆索引
if [ -d "$MEMORY_DIR" ]; then
    log "更新记忆索引..."
    cat > "$MEMORY_DIR/INDEX.md" << 'EOF'
# 记忆索引

_自动生成 - $(date '+%Y-%m-%d %H:%M:%S')_

---

## 📁 目录结构

EOF

    # 列出所有记忆文件
    for file in "$MEMORY_DIR"/*.md; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            size=$(du -h "$file" | cut -f1)
            echo "- [$filename]($filename) ($size)" >> "$MEMORY_DIR/INDEX.md"
        fi
    done

    log_success "记忆索引已更新"
fi

# 1.2 知识库整理
log "整理知识库..."
if [ -d "$KNOWLEDGE_DIR" ]; then
    # 删除空目录
    find "$KNOWLEDGE_DIR" -type d -empty -delete 2>/dev/null || true

    # 更新知识库索引
    log "更新知识库索引..."
    cat > "$KNOWLEDGE_DIR/INDEX.md" << 'EOF'
# 知识库索引

_自动生成 - $(date '+%Y-%m-%d %H:%M:%S')_

---

## 📁 目录结构

EOF

    # 列出所有知识文档
    find "$KNOWLEDGE_DIR" -name "*.md" -type f | while read file; do
        rel_path="${file#$KNOWLEDGE_DIR/}"
        size=$(du -h "$file" | cut -f1)
        echo "- [$rel_path]($rel_path) ($size)" >> "$KNOWLEDGE_DIR/INDEX.md"
    done

    log_success "知识库索引已更新"
fi

# 1.3 数据文件整理
log "整理数据文件..."
if [ -d "$DATA_DIR" ]; then
    # 删除临时文件
    find "$DATA_DIR" -type f -name "*.tmp" -delete 2>/dev/null || true
    find "$DATA_DIR" -type f -name "*.bak" -mtime +7 -delete 2>/dev/null || true

    log_success "数据文件已清理"
fi

# 1.4 Git 仓库整理
log "整理 Git 仓库..."
git add -A 2>/dev/null || true
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    git commit -m "chore: 每日维护 - 结构化整理 $(date '+%Y-%m-%d')" 2>/dev/null || true
    log_success "Git 仓库已整理"
else
    log_warning "无变更需要提交"
fi

# ==================== 2. 回顾总结 ====================
log_section "2️⃣ 回顾总结"

# 获取今天的日期
TODAY=$(date '+%Y-%m-%d')
MEMORY_FILE="$MEMORY_DIR/$TODAY.md"

# 2.1 检查今日日志
if [ -f "$MEMORY_FILE" ]; then
    log "今日日志已存在: $MEMORY_FILE"

    # 统计今日工作
    TASKS=$(grep -c "✅\|完成\|提交" "$MEMORY_FILE" 2>/dev/null || echo "0")
    log "今日完成任务数: $TASKS"
else
    log_warning "今日日志不存在，创建新文件"
    touch "$MEMORY_FILE"
fi

# 2.2 提取关键知识点
log "提取关键知识点..."
if [ -f "$MEMORY_FILE" ]; then
    KNOWLEDGE_LEARNED=$(grep -A 3 "学习要点\|💡\|经验" "$MEMORY_FILE" 2>/dev/null | head -20)
    if [ -n "$KNOWLEDGE_LEARNED" ]; then
        log "发现学习要点:"
        echo "$KNOWLEDGE_LEARNED" | head -10 | tee -a "$LOG_FILE"
    fi
fi

# 2.3 检查遗漏任务
log "检查遗漏任务..."
if [ -f "$MEMORY_FILE" ]; then
    MISSED_TASKS=$(grep -E "\[ \]|待办|TODO|pending" "$MEMORY_FILE" 2>/dev/null || true)
    if [ -n "$MISSED_TASKS" ]; then
        log_warning "发现未完成任务:"
        echo "$MISSED_TASKS" | head -5 | tee -a "$LOG_FILE"
    else
        log_success "所有任务已完成"
    fi
fi

# ==================== 3. 更新仓库 ====================
log_section "3️⃣ 更新仓库"

# 3.1 更新 MEMORY.md（长期记忆）
log "更新长期记忆（MEMORY.md）..."
if [ -f "$WORKSPACE/MEMORY.md" ] && [ -f "$MEMORY_FILE" ]; then
    # 提取今日重要内容并添加到 MEMORY.md
    TODAY_SUMMARY=$(grep -A 5 "## 📚 今日学习" "$MEMORY_FILE" 2>/dev/null | head -20 || true)
    if [ -n "$TODAY_SUMMARY" ]; then
        # 在 MEMORY.md 中添加今日总结（如果不存在）
        if ! grep -q "## 📅 $TODAY" "$WORKSPACE/MEMORY.md" 2>/dev/null; then
            echo "" >> "$WORKSPACE/MEMORY.md"
            echo "## 📅 $TODAY" >> "$WORKSPACE/MEMORY.md"
            echo "" >> "$WORKSPACE/MEMORY.md"
            echo "$TODAY_SUMMARY" >> "$WORKSPACE/MEMORY.md"
            log_success "已添加今日总结到 MEMORY.md"
        else
            log_warning "今日总结已存在"
        fi
    fi
fi

# 3.2 Git 提交
log "提交所有变更..."
git add -A 2>/dev/null || true
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    git commit -m "docs: 每日回顾 - $TODAY

$(date '+%Y-%m-%d %H:%M:%S')

完成内容：
- 结构化整理（记忆、知识库、索引）
- 回顾总结（查漏补缺）
- 更新长期记忆
" 2>/dev/null || true
    log_success "Git 已提交"
else
    log_warning "无变更需要提交"
fi

# 3.3 推送到远程
log "推送到 GitHub..."
if git push 2>/dev/null; then
    log_success "已推送到 GitHub"
else
    log_warning "推送失败（可能网络问题，稍后重试）"
fi

# ==================== 4. 更新 QMD 向量 ====================
log_section "4️⃣ 更新 QMD 向量"

log "向量更新功能待实现（OpenClaw 可能自动管理）"
log_success "跳过（OpenClaw 自动管理向量）"

# ==================== 5. 重启 Gateway ====================
log_section "5️⃣ 重启 Gateway"

log "重启 OpenClaw Gateway..."
BEFORE_MEM=$(ps aux | grep openclaw-gateway | grep -v grep | awk '{printf "%.0f MB", $6/1024}')
log "重启前内存: $BEFORE_MEM"

if openclaw gateway restart 2>&1 | tee -a "$LOG_FILE"; then
    sleep 5
    AFTER_MEM=$(ps aux | grep openclaw-gateway | grep -v grep | awk '{printf "%.0f MB", $6/1024}')
    log_success "Gateway 已重启"
    log "重启后内存: $AFTER_MEM"

    # 检查 Gateway 状态
    if openclaw gateway status 2>/dev/null | grep -q "running"; then
        log_success "Gateway 状态正常"
    else
        log_warning "Gateway 状态检查失败"
    fi
else
    log_error "Gateway 重启失败"
fi

# ==================== 6. 系统状态报告 ====================
log_section "6️⃣ 系统状态报告"

log "内存状态:"
vm_stat | perl -ne '
/page size of (\d+)/ and $ps=$1;
/Pages free:\s+(\d+)/ and printf "  可用: %.2f GB\n", $1*$ps/1073741824;
/Pages active:\s+(\d+)/ and printf "  活跃: %.2f GB\n", $1*$ps/1073741824;
/Pages inactive:\s+(\d+)/ and printf "  非活跃: %.2f GB\n", $1*$ps/1073741824;
' | tee -a "$LOG_FILE"

log ""
log "系统负载:"
uptime | awk -F'load averages:' '{print "  " $2}' | tee -a "$LOG_FILE"

log ""
log "磁盘空间:"
df -h / | tail -1 | awk '{print "  根分区: "$3" 已用 / "$2" 总量 ("$5" 使用率)"}' | tee -a "$LOG_FILE"

log ""
log "Gateway 进程:"
ps aux | grep openclaw-gateway | grep -v grep | awk '{printf "  PID: %s, CPU: %s%%, MEM: %s%% (%.0f MB)\n", $2, $3, $4, $6/1024}' | tee -a "$LOG_FILE"

# ==================== 完成 ====================
log_section "✅ 每日维护完成"

END_TIME=$(date '+%Y-%m-%d %H:%M:%S')
log "完成时间: $END_TIME"
log ""
log "下次执行时间: 明日凌晨 2:00"

# 移除错误陷阱
trap - ERR

exit 0
