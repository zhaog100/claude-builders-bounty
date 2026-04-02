#!/usr/bin/env python3
"""
发送跟进邮件 - 带重试机制
"""

import smtplib
from email.mime.text import MIMEText
import time
import sys

# Gmail 配置
SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587
USERNAME = "zhaog100@gmail.com"
APP_PASSWORD = "frbmfuadrhginwls"

# 邮件配置
TO_EMAIL = "scott@rustchain.dev"  # 官方邮箱
CC_EMAIL = "scott@rustchain.dev"  # 抄送

# 邮件内容
SUBJECT = "Follow-up on RustChain Payment (Issue #2755)"
BODY = """Dear Maintainer,

Thank you for merging PR #2205! 

I noticed this PR was merged 9 days ago on 2026-03-17, According to the bounty guidelines, the payment of 15 RTC should due within 3-5 business days.

However, I haven't received any payment confirmation yet.

Could you please update me on this status?

**Payment Details:**
- Wallet: RTCb72a1accd46b9ba9f22dbd4b5c6aad5a5831572b
- Platform: RustChain
- Expected Payment: 15 RTC
- Reference: PR #2205 - https://github.com/Scottcjn/rustchain-bounties/pull/2205
- Claim Issue: #2755 - https://github.com/Scottcjn/rustchain-bounties/issues/2755
- Merged Date: 2026-03-17
- Days Overdue: 9 days

**Alternative Contact:**
- GitHub: @zhaog100
- Email: zhaog100@gmail.com

Thank you!

Best regards,
Xiaomili 🌾
Bounty Hunter & Developer
"""

def send_email_with_retry(max_retries=3, retry_delay=5):
    """带重试机制的邮件发送"""
    for attempt in range(max_retries):
        try:
            print(f"\n📧 尝试发送邮件 (尝试 {attempt + 1}/{max_retries})...")
            print(f"收件人: {TO_EMAIL}")
            print(f"主题: {SUBJECT}")
            
            # 创建邮件
            msg = MIMEText(BODY)
            msg['Subject'] = SUBJECT
            msg['From'] = USERNAME
            msg['To'] = TO_EMAIL
            msg['Cc'] = CC_EMAIL
            
            # 连接到 SMTP 服务器
            print("🔗 连接到 Gmail SMTP...")
            smtp = smtplib.SMTP(SMTP_SERVER, SMTP_PORT, timeout=15)
            
            print("🔐 启动 TLS 加密...")
            smtp.starttls()
            
            print("🔑 登录中...")
            smtp.login(USERNAME, APP_PASSWORD)
            
            # 发送邮件
            print("📤 发送邮件...")
            smtp.send_message(msg)
            smtp.quit()
            
            print("\n" + "="*60)
            print("✅ 邮件发送成功!")
            print("=" * 60)
            print(f"   收件人: {TO_EMAIL}")
            print(f"   主题: {SUBJECT}")
            print(f"   发送时间: {time.strftime('%Y-%m-%d %H:%M:%S')}")
            print("=" * 60)
            return True
            
        except smtplib.SMTPException as e:
            print(f"❌ SMTP 错误 (尝试 {attempt + 1}): {e}")
            if attempt < max_retries - 1:
                print(f"⏳ 等待 {retry_delay} 秒后重试...")
                time.sleep(retry_delay)
            else:
                print(f"❌ 已达到最大重试次数，发送失败")
                return False
        except Exception as e:
            print(f"❌ 发送失败 (尝试 {attempt + 1}): {e}")
            if attempt < max_retries - 1:
                print(f"⏳ 等待 {retry_delay} 秒后重试...")
                time.sleep(retry_delay)
            else:
                print(f"❌ 已达到最大重试次数，发送失败")
                return False

if __name__ == "__main__":
    print("=" * 60)
    print("📧 RustChain 付款跟进邮件")
    print("=" * 60)
    print(f"时间: {time.strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"收件人: {TO_EMAIL}")
    print(f"主题: {SUBJECT}")
    print("=" * 60)
    
    success = send_email_with_retry(max_retries=3, retry_delay=5)
    
    if success:
        print("\n✅ 邮件发送完成!")
        sys.exit(0)
    else:
        print("\n❌ 邮件发送失败")
        print("\n💡 手动方案:")
        print("1. 打开 Gmail: https://mail.google.com")
        print("2. 撰写邮件:")
        print(f"   - 收件人: {TO_EMAIL}")
        print(f"   - 主题: {SUBJECT}")
        print("3. 粘贴邮件内容:")
        print("-" * 60)
        print(BODY)
        print("-" * 60)
        sys.exit(1)
