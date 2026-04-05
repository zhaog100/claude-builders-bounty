#!/usr/bin/env python3
import imaplib
import email
from email.header import decode_header

EMAIL = 'zhaog100@gmail.com'
PASSWORD = 'frbmfuadrhginwls'

def decode_str(s):
    if s is None:
        return ''
    result = ''
    for part, charset in decode_header(s):
        if isinstance(part, bytes):
            result += part.decode(charset or 'utf-8', errors='ignore')
        else:
            result += str(part)
    return result

try:
    mail = imaplib.IMAP4_SSL('imap.gmail.com')
    mail.login(EMAIL, PASSWORD)
    mail.select('INBOX')
    
    # 搜索关键词
    keywords = ['paypal', 'payment', 'bounty', 'invoice', 'crypto', 'usdt', 'rustchain']
    
    print("🔍 正在搜索付款相关邮件...\n")
    
    for keyword in keywords:
        status, data = mail.search(None, f'SUBJECT "{keyword}"')
        
        if data[0]:
            email_ids = data[0].split()
            print(f"\n📧 关键词 '{keyword}': 找到 {len(email_ids)} 封邮件")
            
            for email_id in email_ids[-3:]:  # 只显示最新的3封
                status, msg_data = mail.fetch(email_id, '(RFC822)')
                msg = email.message_from_bytes(msg_data[0][1])
                
                subject = decode_str(msg['Subject'])
                from_addr = decode_str(msg['From'])
                date = msg['Date']
                
                print(f"  主题: {subject}")
                print(f"  发件人: {from_addr}")
                print(f"  时间: {date}")
                print()
    
    mail.close()
    mail.logout()
    print("✅ 检查完成")
    
except Exception as e:
    print(f"❌ 错误: {e}")
