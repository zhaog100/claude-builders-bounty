#!/bin/bash
echo "🧪 测试 Gmail IMAP 连接..."
python3 << 'PYTHON'
import imaplib
import os

env_file = os.path.expanduser('~/.openclaw/workspace/.env')
env = {}
with open(env_file, 'r', encoding='utf-8') as f:
    for line in f:
        line = line.strip()
        if '=' in line and not line.startswith('#'):
            if ' #' in line:
                line = line.split(' #')[0]
            key, value = line.split('=', 1)
            value = value.strip('"').strip("'")
            env[key] = value

email_address = env.get('GMAIL_ADDRESS', '')
app_password = env.get('GMAIL_APP_PASSWORD', '')

try:
    mail = imaplib.IMAP4_SSL('imap.gmail.com')
    mail.login(email_address, app_password)
    print("✅ Gmail IMAP 连接成功！")
    print(f"📧 邮箱: {email_address}")
    mail.logout()
except Exception as e:
    print(f"❌ 连接失败: {e}")
    print("\n请确认：")
    print("1. IMAP 已启用")
    print("2. 应用密码正确")
PYTHON
