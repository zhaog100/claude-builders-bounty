#!/bin/bash
# 防止 MacBook 合盖睡眠
# 仅在使用交流电源时生效

CAFFEINATE_PID=""

# 清理函数：退出时停止 caffeinate
cleanup() {
    if [ ! -z "$CAFFEINATE_PID" ]; then
        kill $CAFFEINATE_PID 2>/dev/null
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 防睡眠已停止" >> ~/.openclaw/workspace/data/prevent-sleep.log
    fi
    exit 0
}

trap cleanup SIGTERM SIGINT

while true; do
    # 检查是否在使用交流电源
    if pmset -g batt | grep -q "AC Power"; then
        # 如果 caffeinate 未运行，则启动
        if [ -z "$CAFFEINATE_PID" ] || ! kill -0 $CAFFEINATE_PID 2>/dev/null; then
            caffeinate -d -i -u &
            CAFFEINATE_PID=$!
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] 防睡眠已启动 (PID: $CAFFEINATE_PID)" >> ~/.openclaw/workspace/data/prevent-sleep.log
        fi
    else
        # 切换到电池电源，停止 caffeinate
        if [ ! -z "$CAFFEINATE_PID" ]; then
            kill $CAFFEINATE_PID 2>/dev/null
            CAFFEINATE_PID=""
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] 切换到电池电源，防睡眠已停止" >> ~/.openclaw/workspace/data/prevent-sleep.log
        fi
    fi

    # 每 60 秒检查一次电源状态
    sleep 60
done
