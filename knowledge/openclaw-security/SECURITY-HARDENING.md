# OpenClaw 3.22 安全加固清单

**版本**: v1.0
**更新时间**: 2026-04-01 17:00 CST
**来源**: OpenClaw 3.22：插件生态大换血，你的"龙虾"安全吗？

---

## ⚠️ 核心安全风险

### 🔴 高危风险

| 检查项 | 风险描述 | 真实案例 |
|--------|---------|----------|
| **Gateway 公网暴露** | 默认端口 1878919890 暴露在互联网 | 某创业公司被扫描爆破 |
| **凭证明文存储** | API Key 存储在 .env 文件 | 任何插件都能读取 |
| **权限滥用** | AI 被诱导执行危险命令 | 用户让 AI "清理垃圾"，删除 /etc/passwd |

### 🟡 中危风险

| 检查项 | 风险描述 |
|--------|---------|
| **插件供应链攻击** | 恶意插件窃取凭证（2026.1 ClawHavoc 事件）|
| **环境隔离不足** | 在主力机上运行 OpenClaw |

---

## 🛡️ 安全加固 7 步法

### ✅ 步骤 1: 环境隔离（最高优先级）

**推荐方案**:
- Docker 容器部署（推荐镜像：`openclaw/openclaw:3.22`）
- 虚拟机（VMware/VirtualBox）
- 闲置旧电脑

**Docker 部署示例**:
```bash
docker run -d \
  --name openclaw \
  --user 1000:1000 \  # 非 root 用户
  --read-only \       # 只读文件系统
  --tmpfs /tmp \      # 临时目录可写
  --cap-drop=ALL \    # 丢弃所有 Linux 能力
  --security-opt=no-new-privileges:true \
  -v ~/openclaw-data:/home/claw/data \
  openclaw/openclaw:3.22
```

---

### ✅ 步骤 2: 网络收敛

**配置 `config.yaml`**:
```yaml
gateway:
  bind: "127.0.0.1"  # 仅本地访问
  port: 1878919890
```

**远程访问方案**:
- Tailscale / ZeroTier 组网
- VPN 访问
- 云服务器安全组：仅开放给可信 IP

**⚠️ 严禁**: 将默认端口直接暴露在互联网上！

---

### ✅ 步骤 3: 权限最小化

**创建专用低权限账户**:
```bash
sudo useradd -r -s /bin/false openclaw
sudo chown -R openclaw:openclaw ~/.openclaw
```

**目录权限限制**:
```bash
chmod 700 ~/.openclaw/credentials  # 凭证目录仅所有者可读写
chmod 755 ~/.openclaw/extensions   # 插件目录只读
```

---

### ✅ 步骤 4: 工具权限精细化管控

**修改 `config.yaml`**:
```yaml
tool_permission_policy: custom  # 推荐：自定义白名单
custom_allowed_tools:
  - file_read
  - file_write
  - messaging
  # - shell_exec  # 谨慎开启！
```

**⚠️ 避免**: 使用 `permissive` 模式（全能模式）

---

### ✅ 步骤 5: 凭证安全管理

**使用环境变量注入**:
```bash
export OPENAI_API_KEY="sk-..."
export GITHUB_TOKEN="ghp_..."
```

**启用凭证加密（3.22 新功能）**:
```bash
openclaw credentials encrypt --all
```

**定期轮换密钥**: 建议每 90 天更换一次

---

### ✅ 步骤 6: 插件来源审查

**只安装官方认证插件**:
- 认准 ClawHub 的 "Verified" 标识
- 拒绝黑灰产插件（"自动赚钱"、"破解"、"撸羊毛"）

**定期清理**:
```bash
openclaw plugin list --unused  # 查看未使用插件
openclaw plugin uninstall <plugin-name>  # 删除不必要插件
```

---

### ✅ 步骤 7: 启用安全审计与监控

**运行自动审计**:
```bash
openclaw security audit  # 自动检测并修复常见配置问题
```

**日志留存**:
```yaml
logging:
  level: info
  output: /var/log/openclaw/audit.log
  retention_days: 90
```

**异常行为告警**: 集成企业 SIEM 系统，监控：
- 深夜高频 Shell 执行
- 大量文件导出操作
- 非常规 API 调用

---

## 📋 安全配置速查表

| 检查项 | 建议配置 | 风险等级 |
|--------|---------|----------|
| 运行环境 | Docker / 虚拟机 | 🔴 高危 |
| 网络暴露 | 仅本地 / VPN | 🔴 高危 |
| 运行权限 | 普通用户 (非 Root) | 🔴 高危 |
| 工具权限 | 最小权限策略 | 🟡 中危 |
| 凭证存储 | 环境变量 + 加密 | 🔴 高危 |
| 插件来源 | ClawHub Verified | 🟡 中危 |
| 日志审计 | 保留 90 天 | 🟢 建议 |

---

## 🚨 紧急检查命令

```bash
# 1. 检查 Gateway 状态
openclaw gateway status

# 2. 加密所有凭证
openclaw credentials encrypt --all

# 3. 运行安全审计
openclaw security audit

# 4. 查看已安装插件
openclaw plugin list
```

---

## 📌 3.22 新功能

### ClawHub 生态
- ✅ 移除 `openclaw/extension-api`，所有插件必须迁移至新 SDK
- ✅ ClawHub 成为唯一官方市场（5705 个 Skills 已审计）
- ✅ 新增 Claude Code、Cursor、Codex 插件支持

### 安全修复
- ✅ SMB 凭证泄露修复
- ✅ 环境变量注入修复（JVM、GLIBC、.NET）
- ✅ Unicode 伪装攻击防护
- ✅ 权限隔离强化

### 模型扩展
- ✅ GPT-5.4（新默认）
- ✅ MiniMax M2.7
- ✅ xAI Grok
- ✅ Google Vertex AI (Anthropic)

---

## 🔐 当前状态（你的环境）

**已检查项目**:
- ✅ 密钥轮换：4 个密钥已更新（2026-04-01）
- ⚠️ Gateway 状态：**未知**
- ⚠️ 凭证加密：**未启用**
- ⚠️ 运行环境：**主力机**（非隔离）

**待办事项**:
- [ ] 检查 Gateway 绑定地址
- [ ] 启用凭证加密
- [ ] 运行安全审计
- [ ] 审查已安装插件

---

## 💡 立即行动

**P0（今天必做）**:
1. 检查 Gateway 是否暴露在公网
2. 加密所有凭证
3. 运行安全审计

**P1（本周完成）**:
1. 配置文件权限
2. 审查已安装插件
3. 启用审计日志

**P2（本月完成）**:
1. 建立密钥轮换机制（90 天周期）
2. 配置 Tailscale/VPN（如果需要远程访问）

---

_最后更新: 2026-04-01 17:00 CST_
