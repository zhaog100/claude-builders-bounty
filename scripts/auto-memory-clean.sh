#!/bin/bash
# 自动内存清理脚本（无需 sudo）

LOG_FILE=~/.openclaw/workspace/data/auto-memory-clean.log
ALERT_LOG=~/.openclaw/workspace/data/system-alerts.log

mkdir -p ~/.openclaw/workspace/data

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

alert() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️ $1" >> "$ALERT_LOG"
}

# 获取当前可用内存
FREE_MB=$(vm_stat | grep "free:" | awk '{print $3}' | tr -d '.' | awk '{printf "%.0f", $1 * 4096 / 1024 / 1024}')
SPECULATIVE_MB=$(vm_stat | grep "speculative:" | awk '{print $3}' | tr -d '.' | awk '{printf "%.0f", $1 * 4096 / 1024 / 1024}')
AVAIL_MB=$((FREE_MB + SPECULATIVE_MB))

log "=== 自动内存清理检查 ==="
log "当前可用内存: ${AVAIL_MB} MB"

# 如果可用内存 < 500 MB，执行清理
if [ "$AVAIL_MB" -lt 500 ]; then
    alert "可用内存不足 500MB (${AVAIL_MB}MB)，开始自动清理..."

    log "清理用户缓存..."
    CACHE_SIZE=$(du -sh ~/Library/Caches 2>/dev/null | awk '{print $1}')
    rm -rf ~/Library/Caches/* 2>/dev/null
    log "✓ 用户缓存已清理 (${CACHE_SIZE})"

    log "清理 npm 缓存..."
    npm cache clean --force 2>/dev/null
    log "✓ npm 缓存已清理"

    log "清理临时文件..."
    rm -rf /tmp/* 2>/dev/null
    log "✓ 临时文件已清理"

    # 检查清理效果
    FREE_MB_AFTER=$(vm_stat | grep "free:" | awk '{print $3}' | tr -d '.' | awk '{printf "%.0f", $1 * 4096 / 1024 / 1024}')
    SPECULATIVE_MB_AFTER=$(vm_stat | grep "speculative:" | awk '{print $3}' | tr -d '.' | awk '{printf "%.0f", $1 * 4096 / 1024 / 1024}')
    AVAIL_MB_AFTER=$((FREE_MB_AFTER + SPECULATIVE_MB_AFTER))

    log "清理后可用内存: ${AVAIL_MB_AFTER} MB (释放 $((AVAIL_MB_AFTER - AVAIL_MB)) MB)"

    if [ "$AVAIL_MB_AFTER" -lt 500 ]; then
        alert "⚠️ 自动清理后可用内存仍不足 (${AVAIL_MB_AFTER}MB)，建议重启系统或关闭不必要的应用"
    fi
else
    log "✓ 可用内存充足 (${AVAIL_MB} MB)，无需清理"
fi

log "===================="
