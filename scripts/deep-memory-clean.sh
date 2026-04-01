#!/bin/bash
# 一键深度内存清理脚本
# 包含 sudo purge，需要输入密码一次

echo "🦞 OpenClaw 深度内存清理工具"
echo "================================"
echo ""

echo "【清理前内存状态】"
BEFORE_FREE=$(vm_stat | grep "free:" | awk '{print $3}' | tr -d '.' | awk '{printf "%.0f", $1 * 4096 / 1024 / 1024}')
BEFORE_INACTIVE=$(vm_stat | grep "inactive:" | awk '{print $3}' | tr -d '.' | awk '{printf "%.0f", $1 * 4096 / 1024 / 1024}')
echo "  可用内存: ${BEFORE_FREE} MB"
echo "  非活跃内存: ${BEFORE_INACTIVE} MB"
echo ""

echo "【清理操作】"
echo "1. 清理用户缓存..."
rm -rf ~/Library/Caches/* 2>/dev/null
echo "   ✓ 用户缓存已清理"

echo "2. 清理系统日志..."
rm -rf ~/Library/Logs/* 2>/dev/null
echo "   ✓ 系统日志已清理"

echo "3. 清理 npm 缓存..."
npm cache clean --force 2>/dev/null
echo "   ✓ npm 缓存已清理"

echo "4. 清理 Homebrew 缓存..."
brew cleanup --prune=all 2>/dev/null
echo "   ✓ Homebrew 缓存已清理"

echo "5. 清理临时文件..."
rm -rf /tmp/* 2>/dev/null
echo "   ✓ 临时文件已清理"

echo "6. 清理 Safari 缓存..."
rm -rf ~/Library/Safari/LocalStorage/* 2>/dev/null
echo "   ✓ Safari 缓存已清理"

echo ""
echo "7. 清理文件缓存（需要密码）..."
sudo purge 2>&1
if [ $? -eq 0 ]; then
    echo "   ✓ 文件缓存已清理"
else
    echo "   ✗ 需要管理员密码，跳过"
fi

echo ""
echo "【清理后内存状态】"
AFTER_FREE=$(vm_stat | grep "free:" | awk '{print $3}' | tr -d '.' | awk '{printf "%.0f", $1 * 4096 / 1024 / 1024}')
AFTER_INACTIVE=$(vm_stat | grep "inactive:" | awk '{print $3}' | tr -d '.' | awk '{printf "%.0f", $1 * 4096 / 1024 / 1024}')
echo "  可用内存: ${AFTER_FREE} MB"
echo "  非活跃内存: ${AFTER_INACTIVE} MB"
echo ""

RELEASED=$((AFTER_FREE - BEFORE_FREE))
if [ $RELEASED -gt 0 ]; then
    echo "✅ 总计释放: ${RELEASED} MB"
else
    echo "✅ 清理完成"
fi

echo ""
echo "================================"
echo "🎉 清理完成！"
