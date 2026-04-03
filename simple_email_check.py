#!/usr/bin/env python3
"""
简单的邮件检查 - 使用 IMAP
"""
import imaplib
import email
from email.header import decode_header
import os

# 读取配置
with open('.env', 'r') as f:
    env = dict(line.strip().split('=', 1) for line in f if '=' in line and not line.startswith('#'))

email_address = env.get('GMAIL_ADDRESS', '')
app_password = env.get('GMAIL_APP_PASSWORD', '')

if not email_address or not app_password:
    print("❌ 未找到 Gmail 配置")
    exit(1)

print(f"📧 检查邮箱: {email_address}")
print("=" * 50)
print()

try:
    # 连接到 Gmail IMAP
    mail = imaplib.IMAP4_SSL('imap.gmail.com')
    mail.login(email_address, app_password)
    
    # 选择收件箱
    mail.select('inbox')
    
    # 搜索最新 10 封邮件
    status, messages = mail.search(None, 'ALL')
    email_ids = messages[0].split()
    
    # 获取最新的 10 封
    latest_ids = email_ids[-10:] if len(email_ids) > 10 else email_ids
    
    print(f"📬 最新 {len(latest_ids)} 封邮件:\n")
    
    for i, email_id in enumerate(reversed(latest_ids), 1):
        status, msg_data = mail.fetch(email_id, '(RFC822)')
        msg = email.message_from_bytes(msg_data[0][1])
        
        # 解码主题
        subject, encoding = decode_header(msg['Subject'])[0]
        if encoding:
            subject = subject.decode(encoding)
        
        # 解码发件人
        from_header, encoding = decode_header(msg['From'])[0]
        if encoding:
            from_header = from_header.decode(encoding)
        
        # 获取日期
        date = msg['Date']
        
        print(f"{i}. {subject}")
        print(f"   发件人: {from_header}")
        print(f"   时间: {date}")
        print()
    
    mail.close()
    
except Exception as e:
    print(f"❌ 错误: {e}")
    import traceback
    traceback.print_exc()

