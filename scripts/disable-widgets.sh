#!/bin/bash

# 自动关闭 macOS 小部件
# 创建时间: 2026-03-31

LOG_FILE="/tmp/widget-killer.log"
WIDGET_NAMES=(
    "StocksWidget"
    "WeatherWidget"
    "ScreenTimeWidgetExtension"
    "WorldClockWidget"
    "CalendarWidgetExtension"
)

echo "$(date): 开始关闭小部件..." >> "$LOG_FILE"

for WIDGET in "${WIDGET_NAMES[@]}"; do
    # 查找并关闭进程
    PIDS=$(ps aux | grep "$WIDGET" | grep -v grep | awk '{print $2}')
    for PID in $PIDS; do
        if [ -n "$PID" ]; then
            kill "$PID" 2>/dev/null && \
                echo "$(date): 关闭 $WIDGET (PID: $PID)" >> "$LOG_FILE"
        fi
    done
done

echo "$(date): 完成" >> "$LOG_FILE"
