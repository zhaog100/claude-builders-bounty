#!/usr/bin/env python3
"""
简单的 Gmail 邮件检查工具
使用 IMAP 协议
"""
import imaplib
import email
from email.header import decode_header
import os
import re

# 读取配置
env_file = os.path.expanduser('~/.openclaw/workspace/.env')
env = {}
with open(env_file, 'r', encoding='utf-8') as f:
    for line in f:
        line = line.strip()
        if '=' in line and not line.startswith('#'):
            # 处理带注释的行
            if ' #' in line:
                line = line.split(' #')[0]
            key, value = line.split('=', 1)
            # 移除引号
            value = value.strip('"').strip("'")
            env[key] = value

email_address = env.get('GMAIL_ADDRESS', '')
app_password = env.get('GMAIL_APP_PASSWORD', '')

print(f"📧 检查邮箱: {email_address}")
print("=" * 60)
print()

try:
    # 连接到 Gmail IMAP
    mail = imaplib.IMAP4_SSL('imap.gmail.com')
    mail.login(email_address, app_password)
    
    print("✅ 连接成功！\n")
    
    # 选择收件箱
    mail.select('INBOX')
    
    # 搜索最新邮件
    status, messages = mail.search(None, 'ALL')
    email_ids = messages[0].split()
    
    if not email_ids:
        print("📭 收件箱为空")
    else:
        # 获取最新 10 封邮件
        latest_ids = email_ids[-10:] if len(email_ids) > 10 else email_ids
        
        print(f"📬 最新 {len(latest_ids)} 封邮件:\n")
        
        for i, email_id in enumerate(reversed(latest_ids), 1):
            status, msg_data = mail.fetch(email_id, '(RFC822)')
            msg = email.message_from_bytes(msg_data[0][1])
            
            # 解码主题
            subject = msg['Subject'] or 'No Subject'
            subject_parts = decode_header(subject)
            decoded_subject = ''
            for part, encoding in subject_parts:
                if isinstance(part, bytes):
                    decoded_subject += part.decode(encoding or 'utf-8', errors='ignore')
                else:
                    decoded_subject += str(part)
            
            # 解码发件人
            from_header = msg['From'] or 'Unknown'
            from_parts = decode_header(from_header)
            decoded_from = ''
            for part, encoding in from_parts:
                if isinstance(part, bytes):
                    decoded_from += part.decode(encoding or 'utf-8', errors='ignore')
                else:
                    decoded_from += str(part)
            
            # 获取日期
            date = msg['Date'] or 'Unknown'
            
            print(f"{i}. {decoded_subject}")
            print(f"   发件人: {decoded_from}")
            print(f"   时间: {date}")
            print()
    
    mail.close()
    mail.logout()
    
except Exception as e:
    print(f"❌ 错误: {e}")
    import traceback
    traceback.print_exc()
