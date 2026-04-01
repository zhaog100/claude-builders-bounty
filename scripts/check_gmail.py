#!/usr/bin/env python3
"""
Gmail 邮件检查脚本
检查最近的 GitHub 付款相关邮件
"""

import os
import sys
import imaplib
import email
from email.header import decode_header
from datetime import datetime, timedelta
import re

# 从环境变量获取配置
GMAIL_USER = os.getenv('GMAIL_ADDRESS', 'zhaog100@gmail.com')
GMAIL_PASS = os.getenv('GMAIL_APP_PASSWORD', '')

if not GMAIL_PASS:
    print("❌ 错误: GMAIL_APP_PASSWORD 环境变量未设置")
    sys.exit(1)

def decode_subject(subject_raw):
    """解码邮件主题"""
    if not subject_raw:
        return ""
    decoded_parts = decode_header(subject_raw)
    subject = ""
    for part, encoding in decoded_parts:
        if isinstance(part, bytes):
            subject += part.decode(encoding or 'utf-8', errors='replace')
        else:
            subject += part
    return subject.strip()

def check_gmail():
    """检查 Gmail 邮件"""
    try:
        # 连接 Gmail IMAP
        print("📧 连接 Gmail...")
        mail = imaplib.IMAP4_SSL('imap.gmail.com')

        # 登录
        print("🔐 登录中...")
        mail.login(GMAIL_USER, GMAIL_PASS)
        print("✅ 登录成功\n")

        # 选择收件箱
        mail.select('INBOX')

        # 搜索最近 7 天的邮件
        since = (datetime.now() - timedelta(days=7)).strftime('%d-%b-%Y')
        print(f"📅 检查 {since} 以来的邮件...\n")

        # 搜索 GitHub 邮件
        status, messages = mail.search(None, f'(FROM "github.com" SINCE {since})')
        email_ids = messages[0].split()

        print(f"📬 找到 {len(email_ids)} 封 GitHub 邮件\n")

        # 关键词
        payment_keywords = [
            'payment', 'paid', 'bounty', 'reward', 'payout',
            'merged', 'congratulations', 'algora', 'sponsorship'
        ]

        payment_emails = []
        github_emails = []

        # 检查每封邮件
        for email_id in reversed(email_ids[:50]):  # 只检查最近 50 封
            status, msg_data = mail.fetch(email_id, '(BODY[HEADER.FIELDS (FROM SUBJECT DATE)])')
            if not msg_data or not msg_data[0]:
                continue

            msg = email.message_from_bytes(msg_data[0][1])
            subject = decode_subject(msg['Subject'])
            date = msg['Date']

            # 检查是否包含付款关键词
            subject_lower = subject.lower()
            is_payment = any(keyword in subject_lower for keyword in payment_keywords)

            if is_payment:
                payment_emails.append({
                    'date': date[:30] if date else 'Unknown',
                    'subject': subject[:80],
                    'keywords': [k for k in payment_keywords if k in subject_lower]
                })

            # 记录 GitHub 邮件
            github_emails.append({
                'date': date[:30] if date else 'Unknown',
                'subject': subject[:80]
            })

        # 显示结果
        print("=" * 80)
        print("💰 付款相关邮件")
        print("=" * 80)

        if payment_emails:
            for i, email_data in enumerate(payment_emails[:10], 1):
                print(f"\n{i}. {email_data['date']}")
                print(f"   {email_data['subject']}")
                print(f"   关键词: {', '.join(email_data['keywords'])}")
        else:
            print("\n❌ 未找到付款相关邮件")

        print("\n" + "=" * 80)
        print("📬 最近的 GitHub 邮件（前 10 封）")
        print("=" * 80)

        for i, email_data in enumerate(github_emails[:10], 1):
            print(f"\n{i}. {email_data['date']}")
            print(f"   {email_data['subject']}")

        # 登出
        mail.logout()
        print("\n✅ 检查完成")

    except imaplib.IMAP4.error as e:
        print(f"\n❌ IMAP 错误: {e}")
        print("\n可能的原因:")
        print("  1. 应用密码不正确")
        print("  2. Gmail IMAP 未启用")
        print("  3. 需要在 Gmail 设置中启用不够安全的应用访问")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ 错误: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__':
    check_gmail()
