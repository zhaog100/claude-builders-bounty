#!/bin/bash
# 防止 MacBook 合盖睡眠 - 更可靠的版本
# 使用 caffeinate -s 防止系统睡眠

LOG_FILE=~/.openclaw/workspace/data/prevent-sleep.log
GATEWAY_PID=""

# 清理函数
cleanup() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 收到停止信号，清理中..." >> "$LOG_FILE"
    # 清理 caffeinate 锁文件
    rm -f /tmp/openclaw-caffeinate.lock
    exit 0
}

trap cleanup SIGTERM SIGINT

# 检查并获取 Gateway PID
get_gateway_pid() {
    ps aux | grep '[o]penclaw-gateway' | awk '{print $2}' | head -1
}

# 主循环
while true; do
    # 检查是否在使用交流电源
    if pmset -g batt | grep -q "AC Power"; then
        # 获取 Gateway PID
        NEW_GATEWAY_PID=$(get_gateway_pid)

        if [ ! -z "$NEW_GATEWAY_PID" ]; then
            if [ "$GATEWAY_PID" != "$NEW_GATEWAY_PID" ]; then
                GATEWAY_PID=$NEW_GATEWAY_PID
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] 检测到 Gateway (PID: $GATEWAY_PID)" >> "$LOG_FILE"
            fi

            # 使用 caffeinate -s 防止系统睡眠（与 -d 不同，-s 更稳定）
            # -s: 防止系统睡眠（即使合盖）
            # -w $GATEWAY_PID: 只要 Gateway 进程在运行，就保持防睡眠
            if [ ! -f /tmp/openclaw-caffeinate.lock ]; then
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] 启动防睡眠 (监控 Gateway PID: $GATEWAY_PID)" >> "$LOG_FILE"
                touch /tmp/openclaw-caffeinate.lock
            fi

            # 持续运行 caffeinate，监控 Gateway 进程
            caffeinate -s -w "$GATEWAY_PID" 2>/dev/null

            # 如果 caffeinate 退出，记录日志
            if [ -f /tmp/openclaw-caffeinate.lock ]; then
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] caffeinate 退出，重新启动..." >> "$LOG_FILE"
                rm -f /tmp/openclaw-caffeinate.lock
            fi
        else
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] 警告: Gateway 未运行" >> "$LOG_FILE"
        fi
    else
        # 电池模式，不防睡眠
        if [ -f /tmp/openclaw-caffeinate.lock ]; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] 切换到电池模式，停止防睡眠" >> "$LOG_FILE"
            rm -f /tmp/openclaw-caffeinate.lock
        fi
    fi

    # 短暂等待后继续
    sleep 5
done
