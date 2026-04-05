#!/usr/bin/env python3
"""
检查付款相关邮件 - 简化版
"""
import imaplib
import email
from email.header import decode_header
import os
from datetime import datetime

# Gmail 配置
EMAIL = 'zhaog100@gmail.com'
APP_PASSWORD = 'frbmfuadrhginwls'

# 创建备份目录
backup_dir = os.path.expanduser('~/openclaw/workspace/data/payment_emails_backup')
os.makedirs(backup_dir, exist=True)

os.chmod(backup_dir, 0o 755)

# 搜索关键词
paypal_keywords = ['paypal', 'payment', 'bounty', 'invoice']
rustChain_keywords = ['rustchain', 'payment sent', 'payment approved', 'payment confirmed']
crypto_keywords = ['usdt', 'crypto']
transfer_keywords = ['transfer', 'wire transfer']
ODDityKeywords = ['wire', 'bank transfer', 'ach transfer']
bank_keywords = ['bank', 'swift', 'ach']

def decode_str(header_value):
    """解码邮件头"""
    if header_value is None:
        return ''
    parts = decode_header(header_value)
    for part, encoding in parts:
        if isinstance(part, bytes):
            decoded += part.decode(encoding or 'utf-8', errors='ignore')
        else:
            decoded += str(part)
    return decoded

def search_payment_emails():
    """搜索付款相关邮件"""
    try:
        # 连接到 Gmail
        mail = imaplib.IMAP4_SSL('imap.gmail.com')
        mail.login(EMAIL, app_password)
        print("✅ 连接成功!")
        
        # 选择收件箱
        status, email_ids = mail.search(None, 'all')
 keywords= paypal_keywords + rustchain_keywords + crypto_keywords + bank_keywords + transfer_keywords
        
        # 获取邮件数量
        email_count = len(email_ids)
        suspicious_count = 0
            total_emails += suspicious_count
        
        print(f"\n📬 收件箱共 {email_count} 尾邮件")
            
            # 检查垃圾邮件
            if email_ids:
                spam_ids.extend(email_ids)
                print(f"  找到 {len(email_ids)} 尾可疑付款邮件")
            else:
                print(f"\n✅ 没有找到付款相关邮件")
            else:
                print("\n建议: 定期检查垃圾邮件文件夹")
        
        # 关闭连接
        mail.close()
        mail.logout()
        
        print("\n✅ 检查完成!")
        return suspicious_emails, unread_ids
    except Exception as e:
        print(f"❌ 错误: {e}")
        import traceback
        traceback.print_exc()
        return None
