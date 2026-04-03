import os
import json
import base64
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from pathlib import Path

def check_email():
    # 读取配置
    env_file = Path('.env')
    if not env_file.exists():
        print("❌ .env 文件不存在")
        return
    
    with open('.env', 'r') as f:
        env = {}
        for line in f:
            if '=' in line and not line.strip().startswith('#'):
                key, value = line.strip().split('=', 1)
                env[key] = value
    
    email_address = env.get('GMAIL_ADDRESS', '')
    print(f"📧 检查邮箱: {email_address}\n")
    
    # 检查 token 文件
    token_file = Path('.gmail_token.json')
    if not token_file.exists():
        print("❌ 未找到 Gmail token")
        print("\n📝 需要先授权 Gmail 访问:")
        print("1. 运行授权脚本")
        print("2. 或手动创建 .gmail_token.json")
        return
    
    try:
        with open('.gmail_token.json', 'r') as f:
            token_data = json.load(f)
        
        creds = Credentials.from_authorized_user_info(token_data)
        
        if creds.expired:
            print("⚠️ Token 已过期，需要重新授权")
            return
        
        service = build('gmail', 'v1', credentials=creds)
        
        # 获取最新邮件
        results = service.users().messages().list(
            userId='me', 
            maxResults=10, 
            labelIds=['INBOX'],
            q='is:unread'
        ).execute()
        messages = results.get('messages', [])
        
        if not messages:
            print("✅ 没有未读邮件")
            return
        
        print(f"📬 发现 {len(messages)} 封未读邮件:\n")
        
        for i, msg in enumerate(messages, 1):
            msg_data = service.users().messages().get(
                userId='me', 
                id=msg['id'], 
                format='metadata',
                metadataHeaders=['From', 'Subject', 'Date']
            ).execute()
            
            headers = {h['name']: h['value'] for h in msg_data['payload']['headers']}
            
            print(f"{i}. {headers.get('Subject', 'No Subject')}")
            print(f"   发件人: {headers.get('From', 'Unknown')}")
            print(f"   时间: {headers.get('Date', 'Unknown')}")
            print()
        
    except Exception as e:
        print(f"❌ 错误: {e}")

if __name__ == '__main__':
    check_email()
