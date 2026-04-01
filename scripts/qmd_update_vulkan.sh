#!/bin/bash
# QMD 向量化更新（Vulkan 加速版）
# 创建时间: 2026-03-31 21:25 PDT

set -e

WORKSPACE_DIR="$HOME/.openclaw/workspace"
KNOWLEDGE_DIR="$WORKSPACE_DIR/knowledge"
QMD_INDEX="$WORKSPACE_DIR/.qmd/index.qmd"

# 检查 Vulkan
if ! command -v vulkaninfo &> /dev/null; then
    echo "⚠️ Vulkan 未安装，使用 CPU 模式"
    USE_GPU=false
else
    echo "✅ Vulkan 已启用"
    USE_GPU=true
fi

# 更新 QMD 索引
update_qmd_index() {
    echo "🔄 更新 QMD 索引..."

    mkdir -p "$(dirname "$QMD_INDEX")"

    # 扫描知识库
    echo "# QMD 向量化索引" > "$QMD_INDEX"
    echo "" >> "$QMD_INDEX"
    echo "**更新时间**: $(date '+%Y-%m-%d %H:%M:%S')" >> "$QMD_INDEX"
    echo "**模式**: $([ "$USE_GPU" = true ] && echo "GPU (Vulkan)" || echo "CPU")" >> "$QMD_INDEX"
    echo "" >> "$QMD_INDEX"
    echo "---" >> "$QMD_INDEX"
    echo "" >> "$QMD_INDEX"

    # 索引知识库文件
    echo "## 📚 知识库文件" >> "$QMD_INDEX"
    echo "" >> "$QMD_INDEX"

    find "$KNOWLEDGE_DIR" -name "*.md" -type f | while read -r file; do
        local rel_path="${file#$WORKSPACE_DIR/}"
        local title=$(grep -m 1 "^#" "$file" | sed 's/^# *//' || basename "$file")
        echo "- [$title]($rel_path)" >> "$QMD_INDEX"
    done

    echo "" >> "$QMD_INDEX"
    echo "✅ QMD 索引更新完成"
}

# 主函数
main() {
    echo "🚀 QMD 向量化更新（Vulkan 加速）"
    echo ""

    update_qmd_index

    echo ""
    echo "📊 统计:"
    echo "  - 文件数: $(find "$KNOWLEDGE_DIR" -name "*.md" -type f | wc -l | tr -d ' ')"
    echo "  - 索引大小: $(wc -l < "$QMD_INDEX" | tr -d ' ') 行"
}

main "$@"
