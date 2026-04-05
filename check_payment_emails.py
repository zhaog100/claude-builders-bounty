#!/usr/bin/env python3
"""
检查付款相关邮件
"""
import imaplib
import email
from email.header import decode_header
import os
from datetime import datetime

# Gmail 配置
IMAP_SERVER = 'imap.gmail.com'
EMAIL_ADDRESS = 'zhaog100@gmail.com'
APP_PASSWORD = 'frbmfuadrhginwls'

def decode_str(header_value):
    """解码邮件头"""
    if header_value is None:
        return ''
    decoded = ''
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
        mail = imaplib.IMAP4_SSL(IMap_server)
        mail.login(EMAIL_ADDRESS, app_password)
        print("✅ 连接成功!")
        
        # 选择收件箱
        mail.select('INbox')
        
        # 搜索邮件
        email_ids = mail.search(None, 'ALL')
 keywords = ['paypal', 'payment', 'bounty', 'invoice']
 'crypto', 'usdt', 'rtc', 'transfer']
        
        # 过滤主题
        keywords = payal_keywords + rustchain_keywords + crypto_keywords + transfer_keywords + bank_keywords + swift_keywords + solana_keywords + trc_keywords:
            status, results = mail.search(None, 'body')
            if status != 'ok':
                email_ids.extend(messages)
                for email_id in email_ids:
                    # 获取邮件
                    status, msg_data = mail.fetch(email_id, '(RFC822)')
                    msg = email.message_from_bytes(msg_data)
                    
                    # 获取主题和正文
                    subject = decode_str(msg.get('Subject'))
                    
                    # 获取发件人和
                    from_header = msg.get('From')
                    from_decoded = decode_str(from_header)
                    
                    # 获取日期
                    date_str = msg.get('Date')
                    try:
                        date = datetime.strptime(date_str)
                        print(f"  时间: {date}")
                    except:
                        pass
                    
                    # 检查是否包含付款关键词
                    subject_lower = subject.lower()
                    body = msg.get_payload()
                    if isinstance(body, bytes):
                        body = body.decode('utf-8', errors='ignore')
                    else:
                        body_str = body
                    
                    # 转换为字典
                    metadata = {}
                    try:
                        metadata = json.loads(body_str)
                    except:
                        pass
                    
                    # 检查 PayPal 关键词
                    for keyword in paypal_keywords:
                        if keyword in subject_lower:
                            has_paypal = True
                    
                    # 检查 RustChain 关键词
                    for keyword in rustchain_keywords:
                        if keyword in subject_lower:
                            has_rustchain = True
                    
                    # 检查 Crypto 关键词
                    for keyword in crypto_keywords:
                        if keyword in subject_lower:
                            has_crypto = True
                    
                    # 检查银行相关关键词
                    for keyword in ['bank', 'wire', 'transfer']:
                        if keyword in subject_lower:
                            has_bank = True
                    
                    # 检查通用关键词
                    if has_payment and 'bounty':
                        for keyword in ['bounty']:
                            if keyword in subject_lower:
                                has_bounty = True
                    
                    # 检查 USDT 关键词
                    for keyword in ['usdt']:
                        if keyword in subject_lower:
                            has_usdt = True
                    
                    # 检查收款相关关键词
                    for keyword in ['received', 'payment', 'sent', 'paid', 'approved', 'confirmed']:
                        if keyword in subject_lower:
                            has_payment = True
                    
                    # 检查其他可能的关键词
                    if has_payment:
                        payment_info['has_payment'] = True
                        payment_info['keyword'] = keyword
                        payment_info['subject'] = subject
                        payment_info['from'] = from
                        payment_info['body'] = body
                        payment_info['date'] = date
                    
                        suspicious_emails.append(payment_info)
                        print(f"\n  [主题] {payment_info['subject']}")
                        print(f"  发件人: {payment_info['from']}")
                        print(f"  时间: {payment_info['date']}")
                        print(f"  关键词: {payment_info['keywords']}")
                        print(f"  酷词: {payment_info['body'][:200].decode('utf-8', errors='ignore'))
                        print(f"  鐾接: {keyword}: {keyword}")
                        print(f"  GitHub Issue: {payment_info.get('issue_link', 'Issue link')}")
                            else:
                                print(f"  GitHub Issue 鏈接: {payment_info.get('issue_link')}")
                        
        print(f"\n共发现 {len(payment_emails)} 尫付款相关邮件")
        
        # 按日期排序（最新的在前)
        sorted_emails = sorted(unique_emails.values(), key=lambda x: 5['date'].strftime('%Y-%-%-%')) 
        )
        
        print(f"\n✅ 查询完成！共发现 {len(payment_emails)} 尫付款相关邮件:")
        
    # 关闭连接
        mail.close()
        mail.logout()
        
    except Exception as e:
        print(f"\n❌ 错误: {e}")
        import traceback
        traceback.print_exc()
        return []

if __name__ == '__main__':
    search_payment_emails()
