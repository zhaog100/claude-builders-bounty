# Mosquitto 安全配置指南

**创建时间**: 2026-03-31
**最后更新**: 2026-03-31 07:27 PDT

---

## 📋 概述

Mosquitto 是轻量级 MQTT Broker，广泛用于物联网和智能家居。本文档介绍安全配置最佳实践。

---

## 🔒 安全配置要点

### 1️⃣ 禁用匿名访问

**默认行为**: Mosquitto 2.0+ 默认禁用匿名访问

```conf
# mosquitto.conf
allow_anonymous false
```

**验证**:
```bash
# 匿名连接应该被拒绝
mosquitto_sub -h localhost -t test
# 输出: Connection refused
```

---

### 2️⃣ 密码认证

#### 创建密码文件

```bash
# 创建新密码文件（-c 选项）
mosquitto_passwd -c /mosquitto/passwordfile homeassistant
# 输入密码: ***

# 添加更多用户
mosquitto_passwd /mosquitto/passwordfile nodered
mosquitto_passwd /mosquitto/passwordfile zigbee2mqtt
```

#### 配置密码文件

```conf
# mosquitto.conf
password_file /mosquitto/passwordfile
```

#### Docker 中使用

```bash
# 使用 Docker 容器创建密码
docker run --rm -v $(pwd)/config/mosquitto:/mosquitto eclipse-mosquitto:2.0.19 \
  mosquitto_passwd -c /mosquitto/passwordfile homeassistant
```

---

### 3️⃣ 访问控制 (ACL)

#### 创建 ACL 文件

```conf
# mosquitto/acl

# 全局规则
pattern write homeassistant/%c/status
pattern read homeassistant/%c/#

# 用户权限
user homeassistant
topic readwrite homeassistant/#
topic readwrite zigbee2mqtt/#
topic readwrite nodered/#

user nodered
topic readwrite nodered/#
topic read homeassistant/#
topic read zigbee2mqtt/#

user zigbee2mqtt
topic readwrite zigbee2mqtt/#
```

#### 配置 ACL

```conf
# mosquitto.conf
acl_file /mosquitto/acl
```

---

### 4️⃣ WebSocket 支持

**用途**: 允许浏览器通过 WebSocket 连接

```conf
# mosquitto.conf

# TCP 监听器（MQTT 协议）
listener 1883
protocol mqtt

# WebSocket 监听器
listener 9001
protocol websockets
```

**客户端连接**:
```javascript
// JavaScript 客户端
const client = new Paho.MQTT.Client("hostname", 9001, "clientId");
client.connect({
  userName: "homeassistant",
  password: "password",
  onSuccess: onConnect
});
```

---

### 5️⃣ TLS/SSL 加密

#### 自签名证书

```bash
# 生成 CA 证书
openssl genrsa -out ca.key 2048
openssl req -new -x509 -days 3650 -key ca.key -out ca.crt

# 生成服务器证书
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key \
  -CAcreateserial -out server.crt -days 3650
```

#### 配置 TLS

```conf
# mosquitto.conf
listener 8883
protocol mqtt
cafile /mosquitto/certs/ca.crt
certfile /mosquitto/certs/server.crt
keyfile /mosquitto/certs/server.key
require_certificate false
```

#### Let's Encrypt 证书

```bash
# 使用 Certbot 获取证书
certbot certonly --standalone -d mqtt.example.com

# 证书路径
# /etc/letsencrypt/live/mqtt.example.com/fullchain.pem
# /etc/letsencrypt/live/mqtt.example.com/privkey.pem
```

---

### 6️⃣ 持久化存储

```conf
# mosquitto.conf

# 持久化消息
persistence true
persistence_location /mosquitto/data/

# 自动保存间隔（秒）
autosave_interval 1800

# 日志
log_dest file /mosquitto/log/mosquitto.log
log_dest stdout
log_type all
```

---

## 📊 完整配置示例

```conf
# /mosquitto/config/mosquitto.conf

# ============================================================
# Mosquitto 安全配置
# ============================================================

# 持久化
persistence true
persistence_location /mosquitto/data/

# 日志
log_dest file /mosquitto/log/mosquitto.log
log_dest stdout
log_type all

# 安全
allow_anonymous false
password_file /mosquitto/passwordfile
acl_file /mosquitto/acl

# 监听器
# TCP (MQTT)
listener 1883
protocol mqtt

# WebSocket
listener 9001
protocol websockets

# 性能
max_connections -1
max_queued_messages 1000
max_inflight_messages 20
```

---

## 🚀 Docker Compose 配置

```yaml
services:
  mosquitto:
    image: eclipse-mosquitto:2.0.19
    container_name: mosquitto
    restart: unless-stopped
    ports:
      - "1883:1883"
      - "9001:9001"
    volumes:
      - ./config/mosquitto/mosquitto.conf:/mosquitto/config/mosquitto.conf
      - ./config/mosquitto/data:/mosquitto/data
      - ./config/mosquitto/log:/mosquitto/log
      - ./config/mosquitto/passwordfile:/mosquitto/passwordfile
      - ./config/mosquitto/acl:/mosquitto/acl
    environment:
      - TZ=America/Los_Angeles
    networks:
      - homeautomation

networks:
  homeautomation:
    driver: bridge
```

---

## 🔍 验证配置

### 测试连接

```bash
# 订阅测试
mosquitto_sub -h localhost -p 1883 \
  -u homeassistant -P password \
  -t test/topic -v

# 发布测试
mosquitto_pub -h localhost -p 1883 \
  -u homeassistant -P password \
  -t test/topic -m "Hello Mosquitto"
```

### 查看日志

```bash
# 实时日志
tail -f /mosquitto/log/mosquitto.log

# Docker 日志
docker logs mosquitto
```

---

## 🛡️ 安全最佳实践

1. ✅ **禁用匿名访问** - `allow_anonymous false`
2. ✅ **使用强密码** - 至少 12 位，包含字母数字符号
3. ✅ **限制用户权限** - 使用 ACL 控制主题访问
4. ✅ **启用 TLS** - 加密传输数据
5. ✅ **定期更新密码** - 每 90 天更换一次
6. ✅ **监控日志** - 检测异常连接
7. ✅ **限制连接数** - `max_connections`
8. ✅ **持久化存储** - 防止消息丢失

---

## 📚 参考资料

- [Mosquitto 官方文档](https://mosquitto.org/documentation/)
- [Mosquitto 配置文件](https://mosquitto.org/man/mosquitto-conf-5.html)
- [MQTT 协议 (v5.0)](https://docs.oasis-open.org/mqtt/mqtt/v5.0/mqtt-v5.0.html)
- [MQTT 安全最佳实践](https://www.hivemq.com/blog/mqtt-security-fundamentals/)

---

## 💡 故障排查

### 问题 1: 连接被拒绝

**症状**: `Connection refused`

**解决**:
1. 检查 `allow_anonymous` 设置
2. 确认用户名密码正确
3. 检查 ACL 权限

### 问题 2: WebSocket 连接失败

**症状**: 浏览器无法连接

**解决**:
1. 确认 WebSocket 监听器已配置
2. 检查端口是否正确 (9001)
3. 验证防火墙规则

### 问题 3: 消息不持久化

**症状**: 重启后消息丢失

**解决**:
1. 设置 `persistence true`
2. 挂载数据卷
3. 检查文件权限

---

_创建时间: 2026-03-31_
_最后更新: 2026-03-31 07:27 PDT_
