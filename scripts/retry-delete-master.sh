#!/bin/bash
# 自动重试删除远程 master 分支
# 创建时间: 2026-03-31 19:40 PDT

set -e

REPO_DIR="$HOME/.openclaw/workspace"
LOG_FILE="$REPO_DIR/data/retry-delete-master.log"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

cd "$REPO_DIR"

log "=== 开始尝试删除远程 master 分支 ==="

# 检查网络连接
if ! ping -c 1 -W 2 github.com > /dev/null 2>&1; then
    log "❌ 网络不通，跳过本次重试"
    exit 1
fi

# 尝试删除分支
if git push origin --delete master 2>&1 | tee -a "$LOG_FILE"; then
    log "✅ master 分支删除成功！"
    
    # 更新 HEARTBEAT.md，移除此任务
    sed -i '' '/### 删除 xiaomili-skills 远程 master 分支/,/^$/{ /✅ 已完成/d; /^$/d; }' "$REPO_DIR/HEARTBEAT.md"
    
    # 标记为已完成
    sed -i '' 's/### 删除 xiaomili-skills 远程 master 分支/### ✅ 已完成：删除 xiaomili-skills 远程 master 分支/' "$REPO_DIR/HEARTBEAT.md"
    
    log "📝 已更新 HEARTBEAT.md"
    exit 0
elif git push origin --delete master 2>&1 | grep -q "remote ref does not exist"; then
    log "✅ master 分支已不存在（可能已手动删除）"
    
    # 更新 HEARTBEAT.md
    sed -i '' 's/### 删除 xiaomili-skills 远程 master 分支/### ✅ 已完成：删除 xiaomili-skills 远程 master 分支（已手动删除）/' "$REPO_DIR/HEARTBEAT.md"
    
    log "📝 已更新 HEARTBEAT.md"
    exit 0
else
    log "⚠️ 删除失败，网络可能仍不稳定"
    exit 1
fi
