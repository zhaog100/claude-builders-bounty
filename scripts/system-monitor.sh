#!/bin/bash
# 系统监控：电量 + 内存使用情况

LOG_FILE=~/.openclaw/workspace/data/system-monitor.log
ALERT_FILE=~/.openclaw/workspace/data/system-alerts.log

mkdir -p ~/.openclaw/workspace/data

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

alert() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️ $1" >> "$ALERT_FILE"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ALERT: $1" >> "$LOG_FILE"
}

# 获取电池信息
BATTERY_INFO=$(pmset -g batt 2>&1)
BATTERY_PERCENT=$(echo "$BATTERY_INFO" | grep -oE '\d+%' | head -1 | tr -d '%')
BATTERY_STATUS=$(echo "$BATTERY_INFO" | grep -oE '(charging|discharging|charged|AC Power)' | head -1)

# 获取内存信息
VM_STAT_OUTPUT=$(vm_stat)
FREE_PAGES=$(echo "$VM_STAT_OUTPUT" | grep "^Pages free:" | awk '{print $3}' | tr -d '.')
ACTIVE_PAGES=$(echo "$VM_STAT_OUTPUT" | grep "^Pages active:" | awk '{print $3}' | tr -d '.')
INACTIVE_PAGES=$(echo "$VM_STAT_OUTPUT" | grep "^Pages inactive:" | awk '{print $3}' | tr -d '.')
WIRED_PAGES=$(echo "$VM_STAT_OUTPUT" | grep "^Pages wired down:" | awk '{print $4}' | tr -d '.')
SPECULATIVE_PAGES=$(echo "$VM_STAT_OUTPUT" | grep "^Pages speculative:" | awk '{print $3}' | tr -d '.')

# 页面大小 4KB
PAGE_SIZE=4096
FREE_MB=$((FREE_PAGES * PAGE_SIZE / 1024 / 1024))
ACTIVE_MB=$((ACTIVE_PAGES * PAGE_SIZE / 1024 / 1024))
INACTIVE_MB=$((INACTIVE_PAGES * PAGE_SIZE / 1024 / 1024))
WIRED_MB=$((WIRED_PAGES * PAGE_SIZE / 1024 / 1024))
SPECULATIVE_MB=$((SPECULATIVE_PAGES * PAGE_SIZE / 1024 / 1024))
TOTAL_MB=$((ACTIVE_MB + INACTIVE_MB + WIRED_MB + FREE_MB + SPECULATIVE_MB))
USED_MB=$((ACTIVE_MB + INACTIVE_MB + WIRED_MB))
AVAIL_MB=$((FREE_MB + SPECULATIVE_MB))
if [ "$TOTAL_MB" -gt 0 ]; then
    USED_PERCENT=$((USED_MB * 100 / TOTAL_MB))
else
    USED_PERCENT=0
fi
# 记录状态
log "===== 系统监控 ====="
log "电池: ${BATTERY_PERCENT}% ($BATTERY_STATUS)"
log "内存: ${USED_MB}MB / ${TOTAL_MB}MB (${USED_PERCENT}%)"
log "  - 活跃: ${ACTIVE_MB}MB"
log "  - 非活跃: ${INACTIVE_MB}MB"
log "  - 固定: ${WIRED_MB}MB"
log "  - 可用: ${AVAIL_MB}MB"
log "===================="
# 电池告警
if [[ "$BATTERY_STATUS" == "discharging" ]]; then
    if [ "$BATTERY_PERCENT" -lt 20 ]; then
        alert "电量严重不足！${BATTERY_PERCENT}% - 请立即充电"
    elif [ "$BATTERY_PERCENT" -lt 40 ]; then
        alert "电量不足 ${BATTERY_PERCENT}% - 建议充电"
    fi
fi
# 内存告警
if [ "$USED_PERCENT" -gt 90 ]; then
    alert "内存使用过高！${USED_PERCENT}% (${USED_MB}MB / ${TOTAL_MB}MB) - 建议清理内存"
elif [ "$USED_PERCENT" -gt 80 ]; then
    alert "内存使用较高 ${USED_PERCENT}% (${USED_MB}MB / ${TOTAL_MB}MB)"
fi
if [ "$AVAIL_MB" -lt 500 ]; then
    alert "可用内存不足 500MB (${AVAIL_MB}MB) - 可能影响性能"
fi
