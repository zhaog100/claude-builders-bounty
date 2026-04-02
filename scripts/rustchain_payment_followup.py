#!/usr/bin/env python3
"""
RustChain 付款跟进邮件
"""

import smtplib
from email.mime.text import MIMEText
from datetime import datetime
import os
import sys

# Gmail 配置
SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587
USERNAME = "zhaog100@gmail.com"
APP_PASSWORD = "frbmfuadrhginwls"

# 收件人
TO_EMAIL = "scott@rustchain.dev"  # 替换为实际维护者邮箱

# 邮件内容
EMAIL_SUBJECT = "Follow-up on RustChain Payment (Issue #2755)"
EMAIL_BODY = """
Dear Maintainer,

Thank you for merging PR #2205! 

I noticed this PR was merged 9 days ago on 2026-03-17, which according to the bounty guidelines, the payment of 13 RTC should due within 3-5 business days.

However, I haven't received any payment confirmation yet.

Could you please update me on this status?

**Payment Details:**
- Wallet: RTCb72a1accd46b9ba9f22dbd4b5c6aad5a5831572b
- Platform: RustChain
- Expected Payment: 15 RTC
- Reference: PR #2205 - https://github.com/Scottcjn/rustchain-bounties/pull/2205
- Claim Issue: #2755 - https://github.com/Scottcjn/rustchain-bounties/issues/2755

Thank you!

Best regards,
Xiaomili 🌾
"""

def send_follow_up_email():
    """发送跟进邮件"""
    try:
        print(f"\n📧 准备发送跟进邮件到 {TO_EMAIL}...")
        print(f"主题: {EMAIL_SUBJECT}")
        
        # 创建邮件
        msg = MIMEText(EMAIL_BODY)
        msg['Subject'] = EMAIL_SUBJECT
        msg['From'] = USERNAME
        msg['To'] = TO_EMAIL
        
        # 连接到 SMTP 服务器
        print("🔗 连接到 Gmail SMTP...")
        smtp = smtplib.SMTP(SMTP_SERVER, SMTP_PORT, timeout=10)
        smtp.starttls(timeout=10)
        smtp.login(USERNAME, APP_PASSWORD, timeout=10)
        
        # 发送邮件
        print("📤 发送邮件...")
        smtp.send_message(msg)
        smtp.quit()
        
        print("✅ 邮件发送成功！")
        print(f"   收件人: {TO_EMAIL}")
        print(f"   主题: {EMAIL_SUBJECT}")
        return True
        
        
    except smtplib.SMTPException as e:
        print(f"❌ SMTP 错误: {e}")
        return False
    except Exception as e:
        print(f"❌ 发送失败: {e}")
        return False

if __name__ == "__main__":
    print("\n" + "="*60)
    print("📧 RustChain 付款跟进邮件")
    print("+" * 60)
    print("⚠️  注意: 这是自动跟进脚本")
    print("   目的: 友好提醒维护者付款")
    print("   不会影响 PR 合并状态")
    print("   建议: 在 Claim Issue 中添加一条提醒付款的评论")
    print("+" * 60)
    
    send_follow_up_email()
