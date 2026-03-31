#!/bin/bash
# 系统优化脚本 - 清理冗余应用，释放 CPU 和内存
# 创建时间: 2026-03-31 16:35 PDT

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 获取当前时间
START_TIME=$(date +%s)

echo ""
echo "🧹 系统优化脚本"
echo "=================="
echo "开始时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# 1. 关闭小部件
log_info "1️⃣ 关闭小部件..."
WIDGET_PIDS=$(ps aux | grep -iE "Widget|widget" | grep -v grep | awk '{print $2}')
if [ -n "$WIDGET_PIDS" ]; then
    COUNT=0
    echo "$WIDGET_PIDS" | while read pid; do
        PROCESS_NAME=$(ps -p $pid -o comm= 2>/dev/null)
        if kill -9 $pid 2>/dev/null; then
            echo "  ✓ 关闭: $PROCESS_NAME (PID: $pid)"
            COUNT=$((COUNT + 1))
        fi
    done
    log_success "已关闭 $(echo "$WIDGET_PIDS" | wc -l | xargs) 个小部件"
else
    log_info "没有运行的小部件"
fi

# 2. 停止照片分析
log_info "2️⃣ 停止照片分析..."
PHOTO_PID=$(ps aux | grep PhotoAnalysis | grep -v grep | awk '{print $2}')
if [ -n "$PHOTO_PID" ]; then
    kill -9 $PHOTO_PID 2>/dev/null && log_success "已停止照片分析" || log_warning "无法停止照片分析"
else
    log_info "照片分析未运行"
fi

# 3. 停止 knowledge-agent
log_info "3️⃣ 停止 knowledge-agent..."
KNOWLEDGE_PID=$(ps aux | grep knowledge-agent | grep -v grep | awk '{print $2}')
if [ -n "$KNOWLEDGE_PID" ]; then
    kill -9 $KNOWLEDGE_PID 2>/dev/null && log_success "已停止 knowledge-agent" || log_warning "无法停止"
else
    log_info "knowledge-agent 未运行"
fi

# 4. 停止 mediaanalysisd（如果运行）
log_info "4️⃣ 停止 mediaanalysisd..."
MEDIA_PID=$(ps aux | grep mediaanalysisd | grep -v grep | awk '{print $2}')
if [ -n "$MEDIA_PID" ]; then
    sudo kill -9 $MEDIA_PID 2>/dev/null && log_success "已停止 mediaanalysisd" || log_warning "需要管理员权限"
else
    log_info "mediaanalysisd 未运行"
fi

# 5. 清理 DNS 缓存
log_info "5️⃣ 清理 DNS 缓存..."
sudo dscacheutil -flushcache 2>/dev/null && log_success "DNS 缓存已清理" || log_warning "需要管理员权限"

# 6. 清理内存
log_info "6️⃣ 清理内存..."
if sudo purge 2>/dev/null; then
    log_success "内存已清理"
else
    log_warning "需要管理员权限才能清理内存"
fi

# 计算耗时
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# 显示结果
echo ""
echo "📊 优化结果"
echo "============"
echo ""

# 内存状态
log_info "内存状态:"
vm_stat | perl -ne '
    /page size of (\d+)/ and $ps=$1;
    /Pages free:\s+(\d+)/ and printf "  可用: %.1f GB\n", $1*$ps/1073741824;
    /Pages active:\s+(\d+)/ and printf "  活跃: %.1f GB\n", $1*$ps/1073741824;
    /Pages inactive:\s+(\d+)/ and printf "  非活跃: %.1f GB\n", $1*$ps/1073741824;
'

echo ""

# 系统负载
log_info "系统负载:"
uptime | awk -F'load averages:' '{print "  " $2}'

echo ""

# 小部件检查
WIDGET_COUNT=$(ps aux | grep -i widget | grep -v grep | wc -l | xargs)
if [ "$WIDGET_COUNT" -gt 0 ]; then
    log_warning "仍有 $WIDGET_COUNT 个小部件运行（macOS 可能自动重启）"
else
    log_success "所有小部件已关闭"
fi

echo ""
echo "✅ 优化完成 (耗时: ${DURATION}秒)"
echo "完成时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
