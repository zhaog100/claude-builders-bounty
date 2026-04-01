# 🔒 BerriAI/litellm #24530 修复方案

**任务**: 修复 /metrics 端点泄露多租户 PII  
**等级**: S 级（90/100）  
**仓库**: BerriAI/litellm（41,725 stars）  
**创建时间**: 2026-03-31 21:58 PDT

---

## 📋 问题分析

### 漏洞详情
- **类型**: 信息泄露 / 租户隔离绕过
- **CVSS**: 7.5（高危）
- **默认行为**: `/metrics` 端点未认证，暴露 ~2MB Prometheus 指标
- **泄露数据**:
  - `team_alias`: 公司名称和员工邮箱（PII）
  - `user`: 用户邮箱
  - `requester_ip_address`: 客户端 IP
  - `user_agent`: Azure Logic Apps 工作流 ID

---

## 🎯 修复方案（3 个独立 PR）

### PR 1: 默认启用认证 ⭐（最简单）
**目标**: 将认证从 opt-in 改为 opt-out

**修改文件**:
1. `litellm/__init__.py`:
   ```python
   # 修改默认值
   require_auth_for_metrics_endpoint: Optional[bool] = True  # 原为 False
   ```

2. `litellm/proxy/middleware/prometheus_auth_middleware.py`:
   ```python
   # 更新文档注释
   """
   By default, auth IS RUN on the metrics endpoint (secure by default).

   To disable auth (not recommended):
   litellm_settings:
       require_auth_for_metrics_endpoint: false
   """
   ```

**影响**: 破坏性变更，但安全优先

---

### PR 2: 清理敏感标签
**目标**: 移除 PII 字段

**修改文件**:
1. `litellm/types/integrations/prometheus.py`:
   ```python
   # 移除敏感标签
   litellm_proxy_total_requests_metric = [
       # ... 保留其他标签 ...
       # 移除: UserAPIKeyLabelNames.TEAM_ALIAS.value,
       # 移除: UserAPIKeyLabelNames.USER_EMAIL.value,
       # 移除: UserAPIKeyLabelNames.CLIENT_IP.value,
       # 移除: UserAPIKeyLabelNames.USER_AGENT.value,
   ]
   ```

**影响**: 现有监控面板可能需要更新

---

### PR 3: 添加启动警告
**目标**: 提醒用户安全风险

**修改文件**:
1. `litellm/integrations/prometheus.py`:
   ```python
   def _mount_metrics_endpoint():
       # 添加警告
       if not litellm.require_auth_for_metrics_endpoint:
           verbose_proxy_logger.warning(
               "⚠️  SECURITY WARNING: /metrics endpoint is exposed without authentication. "
               "This may leak multi-tenant PII. Set 'require_auth_for_metrics_endpoint: true' "
               "to enable authentication."
           )

       # 原有代码...
   ```

**影响**: 仅日志警告，无破坏性

---

## 📊 实施计划

### Phase 1: PR 1（默认认证）
**时间**: 30 分钟
**风险**: 中（破坏性变更）
**优先级**: 最高

### Phase 2: PR 2（标签清理）
**时间**: 45 分钟
**风险**: 中（影响监控）
**优先级**: 高

### Phase 3: PR 3（启动警告）
**时间**: 15 分钟
**风险**: 低（仅警告）
**优先级**: 中

**总时间**: 约 1.5 小时

---

## 🧪 测试计划

### 本地测试
```bash
# 1. 测试默认认证
curl http://localhost:4000/metrics  # 应返回 401

# 2. 测试 opt-out
# 在 config.yaml 设置 require_auth_for_metrics_endpoint: false
curl http://localhost:4000/metrics  # 应返回指标

# 3. 测试警告日志
# 检查启动日志是否包含警告
```

---

## 📝 PR 描述模板

```markdown
## Summary
Fixes #24530 - /metrics endpoint exposed multi-tenant PII by default

## Changes
- Changed `require_auth_for_metrics_endpoint` default to `True`
- Added startup warning when auth is disabled

## Breaking Change
⚠️ This is a breaking change. Users must explicitly opt-out if they want
unauthenticated /metrics endpoint.

## Test Plan
- [ ] Local testing with default config
- [ ] Verify 401 response without auth
- [ ] Test opt-out configuration
- [ ] Check startup warning
```

---

## ⚠️ 注意事项

1. **破坏性变更**: 需要在 PR 中明确说明
2. **文档更新**: 需要更新部署文档
3. **兼容性**: 考虑添加迁移指南

---

_创建时间: 2026-03-31 21:58 PDT_
