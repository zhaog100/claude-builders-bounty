#!/bin/bash
# ============================================================
# 敏感信息脱敏工具
# 创建时间: 2026-03-31
# 用途: 自动检测和脱敏敏感信息
# ============================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================
# 脱敏函数
# ============================================================

# 脱敏 API Key
mask_api_key() {
    local key="$1"
    if [ ${#key} -lt 8 ]; then
        echo "****"
        return
    fi
    local prefix="${key:0:4}"
    local suffix="${key: -4}"
    echo "${prefix}***...****${suffix}"
}

# 脱敏邮箱
mask_email() {
    local email="$1"
    if [[ ! "$email" =~ @ ]]; then
        echo "$email"
        return
    fi
    local name="${email%%@*}"
    local domain="${email#*@}"
    echo "${name:0:1}***@${domain}"
}

# 脱敏密码
mask_password() {
    local password="$1"
    if [ ${#password} -lt 4 ]; then
        echo "****"
        return
    fi
    local suffix="${password: -4}"
    echo "****${suffix}"
}

# 脱敏电话
mask_phone() {
    local phone="$1"
    if [ ${#phone} -lt 7 ]; then
        echo "****"
        return
    fi
    local prefix="${phone:0:3}"
    local suffix="${phone: -4}"
    echo "${prefix}****${suffix}"
}

# ============================================================
# 检测函数
# ============================================================

# 检测 API Key
detect_api_key() {
    local text="$1"
    
    # GitHub Token
    if echo "$text" | grep -qE 'ghp_[A-Za-z0-9]{36}'; then
        echo "⚠️ 检测到 GitHub Personal Access Token"
    fi
    
    # Gemini API Key
    if echo "$text" | grep -qE 'AIza[A-Za-z0-9_-]{35}'; then
        echo "⚠️ 检测到 Gemini API Key"
    fi
    
    # AWS Access Key
    if echo "$text" | grep -qE 'AKIA[A-Z0-9]{16}'; then
        echo "⚠️ 检测到 AWS Access Key"
    fi
}

# 检测邮箱
detect_email() {
    local text="$1"
    
    if echo "$text" | grep -qE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}'; then
        echo "⚠️ 检测到邮箱地址"
    fi
}

# 检测密码
detect_password() {
    local text="$1"
    
    if echo "$text" | grep -qiE '(password|pwd|pass)\s*[=:]\s*\S+'; then
        echo "⚠️ 检测到密码字段"
    fi
}

# ============================================================
# 扫描函数
# ============================================================

# 扫描文件
scan_file() {
    local file="$1"
    local issues=0
    
    echo -e "\n${BLUE}扫描文件: $file${NC}"
    
    if [ ! -f "$file" ]; then
        echo -e "${YELLOW}文件不存在${NC}"
        return
    fi
    
    # 检测 API Key
    if grep -qE '(ghp_|gho_|ghu_|ghs_|ghr_|AIza|AKIA)[A-Za-z0-9]{16,}' "$file"; then
        echo -e "${RED}✗ 发现 API Key 泄露${NC}"
        ((issues++))
    fi
    
    # 检测邮箱
    if grep -qE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}' "$file"; then
        echo -e "${YELLOW}⚠ 发现邮箱地址${NC}"
        # 显示脱敏后的邮箱
        grep -oE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}' "$file" | \
            head -3 | while read email; do
                echo "  - $(mask_email "$email")"
            done
    fi
    
    # 检测密码
    if grep -qiE '(password|pwd|pass)\s*[=:]\s*\S+' "$file"; then
        echo -e "${RED}✗ 发现密码字段${NC}"
        ((issues++))
    fi
    
    if [ $issues -eq 0 ]; then
        echo -e "${GREEN}✓ 未发现敏感信息${NC}"
    fi
    
    return $issues
}

# 扫描目录
scan_directory() {
    local dir="$1"
    local total_issues=0
    
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}扫描目录: $dir${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    # 扫描 .md 文件
    echo -e "\n${YELLOW}📄 Markdown 文件:${NC}"
    find "$dir" -name "*.md" -type f 2>/dev/null | head -10 | while read file; do
        scan_file "$file"
    done
    
    # 扫描 .json 文件
    echo -e "\n${YELLOW}📊 JSON 文件:${NC}"
    find "$dir" -name "*.json" -type f 2>/dev/null | grep -v node_modules | head -5 | while read file; do
        scan_file "$file"
    done
    
    # 检查 .env 文件
    echo -e "\n${YELLOW}🔐 环境变量文件:${NC}"
    if [ -f "$dir/.env" ]; then
        if grep -q ".env" "$dir/.gitignore" 2>/dev/null; then
            echo -e "${GREEN}✓ .env 已在 .gitignore 中${NC}"
        else
            echo -e "${RED}✗ .env 未在 .gitignore 中${NC}"
            ((total_issues++))
        fi
    fi
}

# ============================================================
# 主函数
# ============================================================

main() {
    case "${1:-help}" in
        "scan")
            scan_directory "${2:-.}"
            ;;
        "file")
            scan_file "${2:-}"
            ;;
        "mask")
            case "$2" in
                "api")
                    mask_api_key "$3"
                    ;;
                "email")
                    mask_email "$3"
                    ;;
                "password")
                    mask_password "$3"
                    ;;
                *)
                    echo "用法: $0 mask {api|email|password} <value>"
                    ;;
            esac
            ;;
        "check")
            echo -e "\n${BLUE}=== 敏感信息检查 ===${NC}"
            echo ""
            echo "📋 检查项目:"
            echo "  1. .env 文件是否被忽略"
            echo "  2. 最近提交是否包含敏感信息"
            echo "  3. 常见敏感文件是否存在"
            echo ""
            
            # 检查 .env
            if [ -f ".env" ]; then
                if grep -q ".env" .gitignore 2>/dev/null; then
                    echo -e "${GREEN}✓ .env 文件已被忽略${NC}"
                else
                    echo -e "${RED}✗ .env 文件未被忽略${NC}"
                fi
            else
                echo -e "${YELLOW}⚠ .env 文件不存在${NC}"
            fi
            
            # 检查最近提交
            echo ""
            echo "📋 检查最近 5 次提交..."
            if git log -5 --patch 2>/dev/null | grep -qE '(password|token|secret|key)\s*[=:]\s*\S+' -i; then
                echo -e "${YELLOW}⚠ 可能包含敏感信息，请手动检查${NC}"
            else
                echo -e "${GREEN}✓ 未发现明显的敏感信息${NC}"
            fi
            
            # 检查敏感文件
            echo ""
            echo "📋 检查敏感文件..."
            for file in credentials.json token.json secrets.json; do
                if [ -f "$file" ]; then
                    echo -e "${YELLOW}⚠ 发现 $file${NC}"
                fi
            done
            
            echo ""
            echo -e "${GREEN}✓ 检查完成${NC}"
            ;;
        "help"|*)
            echo "用法: $0 {scan|file|mask|check}"
            echo ""
            echo "命令:"
            echo "  scan [dir]       - 扫描目录中的敏感信息"
            echo "  file <file>      - 扫描单个文件"
            echo "  mask <type> <v>  - 脱敏指定值"
            echo "  check            - 检查当前环境"
            echo ""
            echo "示例:"
            echo "  $0 scan ."
            echo "  $0 file .env"
            echo "  $0 mask api AIzaSyB1234567890abcdefghijklmnop"
            echo "  $0 mask email zhaog100@gmail.com"
            echo "  $0 check"
            ;;
    esac
}

main "$@"
