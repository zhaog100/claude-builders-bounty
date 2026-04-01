# ⚠️ Vulkan 安装要求

## 问题

Vulkan SDK 安装失败，原因是：

**需要完整 Xcode**:
- ❌ 仅安装 Command Line Tools 不够
- ✅ 需要完整的 Xcode.app（≥ 11.7）
- 📥 从 App Store 安装（约 10GB）

---

## 解决方案

### 方案 1: 安装完整 Xcode（推荐）
```bash
# 从 App Store 安装 Xcode
# 安装完成后：
xcode-select --install
brew install vulkan-tools vulkan-headers molten-vk
```

**时间**: 约 30-60 分钟（取决于网速）

---

### 方案 2: 使用 CPU 模式（立即可用）
```bash
# 运行 CPU 版本的 QMD 更新
bash scripts/qmd_update_vulkan.sh
```

**效果**: 功能完整，速度稍慢

---

## 当前状态

- ✅ vulkan-headers: 已安装
- ❌ vulkan-tools: 需要完整 Xcode
- ❌ molten-vk: 需要完整 Xcode

---

_创建时间: 2026-03-31 21:58 PDT_
