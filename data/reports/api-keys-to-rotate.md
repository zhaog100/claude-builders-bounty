# 🔑 需要更换的 API Key 清单

**创建时间**: 2026-03-31 08:28 PDT  
**状态**: 🔴 紧急 - 需要立即更换  
**提醒时间**: 2026-04-01 09:00 PDT

---

## 🔴 需要更换的 API Key

### 1️⃣ Gemini API Key

**泄露的 Key**: `AIzaSyCkYPw59BS4WQJjUe2jBUXwEKgCgu1z6ms`

**泄露位置**:
- `data/reports/sensitive-data-masking-implementation-2026-03-31.md` (已脱敏)
- `docs/SENSITIVE_DATA_MASKING_POLICY.md` (已脱敏)
- `scripts/sensitive-data-mask.sh` (已脱敏)
- `.env.bak` (已删除)
- Git 历史提交

**撤销步骤**:
1. 访问 https://makersuite.google.com/app/apikey
2. 找到泄露的 Key (AIzaSyCk...)
3. 点击 **删除**
4. 点击 **创建 API 密钥**
5. 复制新的 Key
6. 更新 `.env` 文件：
   ```bash
   GEMINI_API_KEY="新的密钥"
   ```

**优先级**: 🔴 高（立即执行）

---

### 2️⃣ GitHub Personal Access Token

**泄露的 Token**: `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`

**泄露位置**:
- `scripts/bounty_scan.sh` (已替换为环境变量)
- Git 历史提交

**撤销步骤**:
1. 访问 https://github.com/settings/tokens
2. 找到泄露的 Token (ghp_ZqxUi...)
3. 点击 **Delete** 或 **Revoke**
4. 点击 **Generate new token**
5. 选择必要的权限（至少：repo, read:org）
6. 生成并复制新 Token
7. 更新 `.env` 文件：
   ```bash
   GITHUB_TOKEN="新的Token"
   ```

**优先级**: 🔴 高（立即执行）

---

## 📋 检查清单

### 立即执行（今天）

- [ ] **撤销 Gemini API Key**
  - 访问 Google AI Studio
  - 删除旧 Key
  - 生成新 Key

- [ ] **撤销 GitHub Token**
  - 访问 GitHub Settings
  - 删除旧 Token
  - 生成新 Token

### 更新配置

- [ ] **更新 .env 文件**
  ```bash
  GEMINI_API_KEY="新的密钥"
  GITHUB_TOKEN="新的Token"
  ```

- [ ] **测试新密钥**
  ```bash
  # 测试 Gemini API
  curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$GEMINI_API_KEY"
  
  # 测试 GitHub API
  curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
  ```

### 可选执行

- [ ] **清理 Git 历史**（可选）
  - 使用 `git filter-branch` 或 BFG Repo-Cleaner
  - 注意：会重写历史，团队成员需重新克隆

---

## 📅 明日提醒任务

**提醒时间**: 2026-04-01 09:00 PDT  
**提醒方式**: 
- 添加到 `HEARTBEAT.md`
- 在每日回顾中提醒

**提醒内容**:
```
🔴 紧急提醒：需要更换以下 API Key
1. Gemini API Key (AIzaSyCk...)
2. GitHub Token (ghp_ZqxUi...)

请立即执行：
- 访问 https://makersuite.google.com/app/apikey
- 访问 https://github.com/settings/tokens
- 更新 .env 文件
```

---

## 🔍 如何添加到自动提醒

### 方法 1: HEARTBEAT.md

在 `HEARTBEAT.md` 中添加：

```markdown
## 🚨 紧急提醒

**2026-04-01**: 
- [ ] 撤销泄露的 Gemini API Key
- [ ] 撤销泄露的 GitHub Token
- [ ] 更新 .env 文件
```

### 方法 2: Cron 任务

```bash
# 添加到 crontab
0 9 1 4 * echo "🔴 紧急：更换 API Key" | mail -s "API Key 更新提醒" user@example.com
```

---

## 📊 当前状态

| Key | 状态 | 优先级 |
|-----|------|--------|
| Gemini API Key | 🔴 已泄露 | 高 |
| GitHub Token | 🔴 已泄露 | 高 |

---

## 🔒 预防措施

### 1. 使用环境变量

```bash
# ✓ 正确
API_KEY="${GEMINI_API_KEY:-}"

# ✗ 错误
API_KEY="AIzaSyCk..."
```

### 2. 定期轮换

- 每月更换一次 API Key
- 使用短期 Token（30天过期）
- 监控 API 使用情况

### 3. 自动化扫描

```bash
# 每日扫描
0 2 * * * /path/to/sensitive-data-mask.sh scan .
```

---

## 📞 相关文件

- **安全扫描报告**: `data/reports/security-scan-deep-2026-03-31.md`
- **脱敏策略**: `docs/SENSITIVE_DATA_MASKING_POLICY.md`
- **脱敏工具**: `scripts/sensitive-data-mask.sh`
- **环境变量**: `.env` (已被 .gitignore 忽略)

---

## 📝 更新日志

| 日期 | 操作 | 状态 |
|------|------|------|
| 2026-03-31 08:02 | 发现泄露 | ✅ |
| 2026-03-31 08:12 | 修复工作区 | ✅ |
| 2026-03-31 08:15 | 推送到 GitHub | ✅ |
| 2026-04-01 09:00 | 提醒更换 | ⏳ |

---

_创建时间: 2026-03-31 08:28 PDT_
_下次检查: 2026-04-01 09:00 PDT_
