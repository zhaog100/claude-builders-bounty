# Home Assistant 网络模式指南

**创建时间**: 2026-03-31
**最后更新**: 2026-03-31 07:27 PDT

---

## 📋 概述

Home Assistant 在 Docker 中运行时，**必须使用 `network_mode: host`**，以支持本地设备自动发现。

---

## 🔍 为什么必须使用 Host 网络

### 1️⃣ mDNS (Multicast DNS) 设备发现

Home Assistant 使用 mDNS 自动发现本地网络设备：

**支持的设备**:
- **Google Cast**: Chromecast, Google Home, Chromecast Audio
- **Apple AirPlay**: Apple TV, HomePod, AirPort Express
- **Philips Hue**: Hue Bridge (自动发现)
- **Sonos**: 扬声器系统
- **其他**: 智能电视、打印机、网络摄像头

**工作原理**:
- mDNS 使用多播地址 `224.0.0.251` (IPv4) 或 `ff02::fb` (IPv6)
- 设备在本地网络广播 `_service._proto.local` 记录
- Home Assistant 监听并自动配置设备

**Bridge 模式问题**:
- ❌ 容器隔离，无法接收多播流量
- ❌ 即使端口映射，mDNS 也无法工作
- ❌ 设备不会出现在 "Integrations" 页面

---

### 2️⃣ UPnP (Universal Plug and Play)

UPnP 用于自动发现和配置网络设备：

**支持的设备**:
- **路由器**: 自动配置端口转发
- **媒体服务器**: Plex, Emby, Jellyfin
- **网络存储**: NAS 设备
- **智能家居网关**: 某些 Zigbee/Z-Wave 网关

**工作原理**:
- UPnP 使用 SSDP (Simple Service Discovery Protocol)
- 广播地址 `239.255.255.250:1900`
- 设备响应 M-SEARCH 请求

**Bridge 模式问题**:
- ❌ 无法接收 SSDP 广播
- ❌ 无法自动配置路由器
- ❌ 需要手动配置每个设备

---

### 3️⃣ 广播和多播

某些智能家居协议需要广播/多播：

**协议示例**:
- **MQTT Discovery**: Home Assistant 的 MQTT 自动发现
- **WOL (Wake-on-LAN)**: 远程唤醒设备
- **某些 Zigbee 网关**: 需要本地广播

---

## 📊 网络模式对比

| 功能 | Host 模式 | Bridge 模式 |
|------|-----------|-------------|
| **mDNS 发现** | ✅ 完全支持 | ❌ 不支持 |
| **UPnP 发现** | ✅ 完全支持 | ❌ 不支持 |
| **设备自动配置** | ✅ 自动 | ❌ 手动 |
| **性能** | ✅ 最佳 | ⚠️ 轻微开销 |
| **端口冲突** | ⚠️ 需注意 | ✅ 无冲突 |
| **多实例** | ❌ 困难 | ✅ 容易 |
| **安全性** | ⚠️ 完全暴露 | ✅ 网络隔离 |

---

## 🚀 配置示例

### Docker Compose (推荐)

```yaml
services:
  homeassistant:
    image: ghcr.io/home-assistant/home-assistant:2024.9.3
    container_name: homeassistant
    restart: unless-stopped
    # 必须使用 host 网络模式
    network_mode: host
    privileged: true
    volumes:
      - ./config/homeassistant:/config
      - /etc/localtime:/etc/localtime:ro
    environment:
      - TZ=America/Los_Angeles
```

### Docker CLI

```bash
docker run -d \
  --name homeassistant \
  --network=host \
  --privileged \
  -v $(pwd)/config:/config \
  -e TZ=America/Los_Angeles \
  ghcr.io/home-assistant/home-assistant:2024.9.3
```

---

## ⚠️ Bridge 模式替代方案

如果必须使用 Bridge 模式（例如在 Kubernetes 中），可以：

### 方案 1: 手动配置设备

```yaml
# configuration.yaml
# 手动配置 Chromecast
cast:
  media_player:
    - host: 192.168.1.100

# 手动配置 Hue
hue:
  bridges:
    - host: 192.168.1.101
```

### 方案 2: 使用 MQTT 发现

```yaml
# 让设备通过 MQTT 宣告自己
mqtt:
  broker: core-mosquitto
  discovery: true
  discovery_prefix: homeassistant
```

### 方案 3: 使用 Webhook 集成

```yaml
# 设备主动推送状态到 Home Assistant
rest:
  - resource: http://192.168.1.100/api/status
    sensor:
      - name: "Device Status"
```

---

## 🔍 验证网络模式

### 检查容器网络

```bash
# 查看容器网络模式
docker inspect homeassistant | grep NetworkMode

# 输出应该是:
# "NetworkMode": "host"
```

### 测试 mDNS 发现

```bash
# 在容器内测试
docker exec -it homeassistant python3 -c "
import socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
sock.bind(('0.0.0.0', 5353))
print('mDNS 监听正常')
"
```

---

## 📚 参考资料

- [Home Assistant 官方文档](https://www.home-assistant.io/docs/)
- [Docker 网络模式](https://docs.docker.com/network/)
- [mDNS 协议 (RFC 6762)](https://tools.ietf.org/html/rfc6762)
- [UPnP 协议](https://openconnectivity.org/developer/specifications/upnp-resources/upnp/)

---

## 💡 最佳实践

1. ✅ **始终使用 host 网络** - 除非有特殊需求
2. ✅ **在 README 中说明** - 解释为什么需要 host 网络
3. ✅ **提供 Bridge 替代方案** - 注释形式，说明限制
4. ✅ **验证设备发现** - 部署后测试 mDNS/UPnP
5. ⚠️ **注意端口冲突** - 确保主机端口 8123 未被占用

---

_创建时间: 2026-03-31_
_最后更新: 2026-03-31 07:27 PDT_
