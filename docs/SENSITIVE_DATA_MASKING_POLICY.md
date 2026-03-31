# 🔒 敏感信息脱敏策略

**版本**: 2.0  
**最后更新**: 2026-03-31 07:54 PDT  
**状态**: ✅ 已启用

---

## 📋 脱敏规则

### 1️⃣ 绝对不显示的敏感信息

| 类型 | 示例 | 脱敏格式 |
|------|------|----------|
| **API Key** | `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` | `ghp_***...****P0B` |
| **密码** | `MyAppPassword123!` | `****123!` |
| **Token** | `gho_16C7e42F292c6912Ev77e780d8eC5a8caB` | `gho_***...****aB` |
| **邮箱** | `zhaog100@gmail.com` | `z***@gmail.com` |
| **私钥** | `-----BEGIN RSA PRIVATE KEY-----` | `[PRIVATE KEY - 已隐藏]` |
| **电话** | `13812345678` | `138****5678` |
| **身份证** | `110101199001011234` | `110101********1234` |

### 2️⃣ 允许显示的信息

| 类型 | 示例 | 说明 |
|------|------|------|
| **URL** | `https://api.example.com` | 可以显示 |
| **配置路径** | `~/.env` | 可以显示 |
| **用户名** | `zhaog100` | 可以显示 |
| **仓库名** | `github.com/user/repo` | 可以显示 |

---

## 🔍 识别敏感信息的特征

### API Key 格式

```regex
# GitHub Token
ghp_[A-Za-z0-9]{36}
gho_[A-Za-z0-9]{36}
ghu_[A-Za-z0-9]{36}
ghs_[A-Za-z0-9]{36}
ghr_[A-Za-z0-9]{36}

# Gemini API Key
AIza[A-Za-z0-9_-]{35}

# Google API Key
AIza[A-Za-z0-9_-]{35}

# AWS Access Key
AKIA[A-Z0-9]{16}

# Slack Token
xox[baprs]-[0-9]{10,13}-[0-9]{10,13}[a-zA-Z0-9]{24}
```

### 邮箱格式

```regex
[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}
```

### 密码特征

```regex
# 包含 "password", "pwd", "pass" 的行
(?i)(password|pwd|pass)\s*[=:]\s*\S+

# 包含 "secret", "key", "token" 的行
(?i)(secret|key|token)\s*[=:]\s*\S+
```

---

## 🛠️ 自动脱敏工具

### 脱敏函数（Bash）

```bash
# 脱敏 API Key
mask_api_key() {
    local key="$1"
    local prefix="${key:0:4}"
    local suffix="${key: -4}"
    echo "${prefix}***...****${suffix}"
}

# 脱敏邮箱
mask_email() {
    local email="$1"
    local name="${email%%@*}"
    local domain="${email#*@}"
    echo "${name:0:1}***@${domain}"
}

# 脱敏密码
mask_password() {
    local password="$1"
    local suffix="${password: -4}"
    echo "****${suffix}"
}
```

### 使用示例

```bash
# API Key
API_KEY="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"
echo "API Key: $(mask_api_key $API_KEY)"
# 输出: API Key: ghp_***...****P0B

# 邮箱
EMAIL="zhaog100@gmail.com"
echo "Email: $(mask_email $EMAIL)"
# 输出: Email: z***@gmail.com
```

---

## 🔍 检查敏感信息泄露

### 扫描当前对话

```bash
# 扫描 .env 文件
check_env_file() {
    if [ -f ".env" ]; then
        echo "✓ .env 文件存在"
        if grep -q ".env" .gitignore; then
            echo "✓ .env 已在 .gitignore 中"
        else
            echo "✗ .env 未在 .gitignore 中"
        fi
    fi
}

# 扫描最近提交
check_recent_commits() {
    echo "检查最近 5 次提交..."
    git log -5 --patch | grep -E "(password|token|key|secret)" -i && \
        echo "⚠️ 发现可能的敏感信息" || \
        echo "✓ 未发现敏感信息"
}
```

### 扫描文件内容

```bash
# 扫描所有 .md 文件
find . -name "*.md" -type f -exec grep -l "ghp_\|AIza\|password" {} \; 2>/dev/null

# 扫描所有 .json 文件
find . -name "*.json" -type f -exec grep -l "token\|key\|password" {} \; 2>/dev/null
```

---

## 📝 正确的显示方式

### ✅ 正确示例

```bash
# 1. 配置状态
echo "✓ GEMINI_API_KEY 已配置（AIza...z6ms）"

# 2. 验证格式
echo "✓ Token 格式正确（ghp_ 开头）"

# 3. 文件位置
echo "✓ 配置已保存到 ~/.env"

# 4. 测试结果
echo "✓ API 连接成功（使用 AIza...z6ms）"
```

### ❌ 错误示例

```bash
# 1. 显示完整密钥
echo "API Key: AIzaSyB1234567890abcdefghijklmnop"

# 2. 显示完整邮箱
echo "Email: zhaog100@gmail.com"

# 3. 显示完整密码
echo "Password: MyAppPassword123!"
```

---

## 🔐 存储位置

### 敏感信息存储

| 文件 | 用途 | 是否忽略 |
|------|------|----------|
| `~/.openclaw/workspace/.env` | 主要配置 | ✅ 已忽略 |
| `~/.git-credentials` | Git 凭证 | ✅ 系统保护 |
| `~/.ssh/id_rsa` | SSH 私钥 | ✅ 权限 600 |
| `~/.ssh/id_rsa.pub` | SSH 公钥 | ⚠️ 可公开 |

### 模板文件（可提交）

| 文件 | 用途 | 是否提交 |
|------|------|----------|
| `.env.example` | 配置模板 | ✅ 可提交 |
| `credentials.json.example` | 凭证模板 | ✅ 可提交 |

---

## 🚨 应急处理

### 发现敏感信息泄露

1. **立即撤销**
   ```bash
   # GitHub Token
   # 访问 https://github.com/settings/tokens
   # 删除泄露的 Token
   
   # API Key
   # 访问对应平台，重新生成 Key
   ```

2. **清理 Git 历史**
   ```bash
   # 如果已提交到 Git
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch .env" \
     --prune-empty --tag-name-filter cat -- --all
   ```

3. **更新所有密钥**
   - 重新生成所有可能泄露的密钥
   - 更新所有使用该密钥的服务

---

## 📊 检查清单

### 每日检查
- [ ] 检查 .env 是否在 .gitignore 中
- [ ] 检查最近提交是否包含敏感信息
- [ ] 检查日志文件是否泄露信息

### 每周检查
- [ ] 扫描所有文件中的敏感信息
- [ ] 更新过期的 API Key
- [ ] 审查访问权限

### 每月检查
- [ ] 轮换重要密钥
- [ ] 审查第三方服务权限
- [ ] 更新安全策略

---

## 📚 参考资料

- [OWASP 敏感数据暴露](https://owasp.org/www-community/vulnerabilities/Information_exposure_through_query_strings_in_get_request)
- [GitHub Token 安全](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure)
- [Git 忽略敏感文件](https://git-scm.com/docs/gitignore)

---

## 🔄 更新历史

| 日期 | 版本 | 更新内容 |
|------|------|----------|
| 2026-03-31 | 2.0 | 完善脱敏规则，添加自动工具 |
| 2026-03-30 | 1.0 | 初始版本 |

---

_创建时间: 2026-03-30_  
_最后更新: 2026-03-31 07:54 PDT_
