# Bounty 知识库索引

**版本**: v1.0
**更新时间**: 2026-04-01 16:20 CST

---

## 📚 知识库结构

```
knowledge/bounty/
├── README.md                    # 知识库概述
├── SCANNER-GUIDE.md            # 扫描系统使用指南 ⭐ 新增
├── history/                     # 历史记录
│   ├── completed-tasks.md       # 已完成任务
│   └── failed-attempts.md       # 失败记录
├── platform-specific/           # 平台特定指南
│   └── github-bounty-guide.md   # GitHub Bounty 指南
├── references/                  # 参考资料
│   ├── best-practices.md        # 最佳实践
│   └── tools-comparison.md      # 工具对比
├── security-templates/          # 安全模板
│   ├── SECURITY.md              # SECURITY.md 模板
│   └── vulnerability-report.md  # 漏洞报告模板
├── standards/                   # 标准
│   └── quality-evaluation-v2.md # 质量评估标准 v2.0
└── strategies/                  # 策略
    ├── high-value-filter.md     # 高价值任务过滤
    ├── project-selection.md     # 项目选择策略
    └── time-management.md       # 时间管理策略
```

---

## 📖 核心文档

### 1️⃣ 扫描系统

| 文档 | 用途 | 优先级 |
|------|------|--------|
| [SCANNER-GUIDE.md](./SCANNER-GUIDE.md) | 扫描系统使用指南 | ⭐⭐⭐⭐⭐ |
| [README.md](./README.md) | 知识库概述 | ⭐⭐⭐⭐ |

### 2️⃣ 质量标准

| 文档 | 用途 | 优先级 |
|------|------|--------|
| [quality-evaluation-v2.md](./standards/quality-evaluation-v2.md) | 质量评估标准 | ⭐⭐⭐⭐⭐ |
| [high-value-filter.md](./strategies/high-value-filter.md) | 高价值任务过滤 | ⭐⭐⭐⭐ |

### 3️⃣ 策略指南

| 文档 | 用途 | 优先级 |
|------|------|--------|
| [project-selection.md](./strategies/project-selection.md) | 项目选择策略 | ⭐⭐⭐⭐ |
| [time-management.md](./strategies/time-management.md) | 时间管理 | ⭐⭐⭐ |
| [best-practices.md](./references/best-practices.md) | 最佳实践 | ⭐⭐⭐ |

### 4️⃣ 安全模板

| 文档 | 用途 | 优先级 |
|------|------|--------|
| [SECURITY.md](./security-templates/SECURITY.md) | 安全策略模板 | ⭐⭐⭐⭐⭐ |
| [vulnerability-report.md](./security-templates/vulnerability-report.md) | 漏洞报告模板 | ⭐⭐⭐⭐ |

---

## 🔄 知识库维护

### 维护频率

| 任务 | 频率 | 负责人 |
|------|------|--------|
| 更新索引 | 每周 | AI Assistant |
| 添加新案例 | 按需 | AI Assistant |
| 清理过时内容 | 每月 | AI Assistant |
| 更新策略 | 每季度 | 用户 + AI |

### 更新流程

1. **添加新知识**:
   ```bash
   # 1. 创建文档
   vi knowledge/bounty/new-topic.md

   # 2. 更新索引
   vi knowledge/bounty/KNOWLEDGE-BASE-INDEX.md

   # 3. 提交变更
   git add knowledge/bounty/
   git commit -m "📚 添加新知识: new-topic"
   ```

2. **更新现有文档**:
   ```bash
   # 1. 编辑文档
   vi knowledge/bounty/standards/quality-evaluation-v2.md

   # 2. 更新版本号和日期
   # 3. 提交变更
   git commit -am "📝 更新质量评估标准"
   ```

3. **清理过时内容**:
   ```bash
   # 1. 移动到历史目录
   mv knowledge/bounty/old-doc.md knowledge/bounty/history/

   # 2. 更新索引
   vi knowledge/bounty/KNOWLEDGE-BASE-INDEX.md

   # 3. 提交变更
   git commit -am "🗑️ 归档过时文档"
   ```

---

## 📊 知识库统计

**总文档数**: 11 个
- 核心文档: 2 个
- 策略文档: 3 个
- 标准文档: 1 个
- 模板文档: 2 个
- 参考文档: 2 个
- 历史记录: 1 个

**最近更新**: 2026-04-01
- ✅ 新增: SCANNER-GUIDE.md
- ✅ 新增: KNOWLEDGE-BASE-INDEX.md

---

## 🎯 学习路径

### 新手路径

1. 阅读 [README.md](./README.md) - 了解基础概念
2. 阅读 [SCANNER-GUIDE.md](./SCANNER-GUIDE.md) - 学习使用扫描系统
3. 阅读 [quality-evaluation-v2.md](./standards/quality-evaluation-v2.md) - 了解质量标准
4. 阅读 [project-selection.md](./strategies/project-selection.md) - 学习项目选择

### 进阶路径

1. 阅读 [high-value-filter.md](./strategies/high-value-filter.md) - 学习高价值任务识别
2. 阅读 [best-practices.md](./references/best-practices.md) - 学习最佳实践
3. 实践: 完成一个 bounty 任务
4. 记录: 将经验添加到知识库

### 专家路径

1. 优化评分算法
2. 改进扫描策略
3. 撰写案例研究
4. 分享经验

---

## 🔗 相关资源

### 外部资源

- [GitHub Security Lab](https://securitylab.github.com/)
- [HackerOne](https://www.hackerone.com/)
- [Bugcrowd](https://www.bugcrowd.com/)
- [Open Bug Bounty](https://www.openbugbounty.org/)

### 内部资源

- [PR 跟踪系统](../../data/bounty-pr-tracker.json)
- [扫描脚本](../../scripts/bounty_unified_scanner.sh)
- [配置文件](../../.bounty-scanner-config.json)

---

## 📝 贡献指南

### 如何贡献

1. **发现错误**:
   - 创建 Issue
   - 提交 PR 修复

2. **添加新知识**:
   - 创建新文档
   - 更新索引
   - 提交 PR

3. **改进现有内容**:
   - 提出建议
   - 提交改进 PR

### 文档标准

- ✅ 使用 Markdown 格式
- ✅ 包含版本号和更新时间
- ✅ 提供实际示例
- ✅ 保持简洁明了
- ✅ 添加交叉引用

---

## 🔄 更新日志

### v1.0 (2026-04-01)
- ✅ 创建知识库索引
- ✅ 添加扫描系统指南
- ✅ 整理文档结构
- ✅ 建立学习路径

---

_最后更新: 2026-04-01 16:20 CST_
