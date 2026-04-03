#!/usr/bin/env python3
"""
Gmail 授权脚本
"""
import os
import json
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials

# Gmail API 权限
SCOPES = ['https://www.googleapis.com/auth/gmail.readonly']

def authorize_gmail():
    """授权 Gmail API"""
    
    # 读取配置
    with open('.env', 'r') as f:
        env = dict(line.strip().split('=', 1) for line in f if '=' in line and not line.startswith('#'))
    
    print("📧 Gmail 授权向导")
    print("=" * 50)
    print()
    print("⚠️ 注意: 此脚本需要 Google Cloud Console 凭证")
    print("   如果没有凭证文件，请按以下步骤操作:")
    print()
    print("1. 访问: https://console.cloud.google.com/apis/credentials")
    print("2. 创建 OAuth 2.0 客户端 ID")
    print("3. 下载凭证 JSON 文件")
    print("4. 保存为: ~/.openclaw/workspace/credentials.json")
    print()
    
    # 检查凭证文件
    creds_file = 'credentials.json'
    if not os.path.exists(creds_file):
        print(f"❌ 未找到凭证文件: {creds_file}")
        print()
        print("替代方案:")
        print("  使用应用专用密码通过 IMAP 访问 Gmail")
        print("  (更简单，但功能受限)")
        return
    
    # 加载凭证
    flow = InstalledAppFlow.from_client_secrets_file(creds_file, SCOPES)
    
    # 运行授权流程
    credentials = flow.run_local_server(port=8080)
    
    # 保存 token
    token_data = {
        'token': credentials.token,
        'refresh_token': credentials.refresh_token,
        'token_uri': credentials.token_uri,
        'client_id': credentials.client_id,
        'client_secret': credentials.client_secret,
        'scopes': credentials.scopes
    }
    
    with open('.gmail_token.json', 'w') as f:
        json.dump(token_data, f)
    
    print()
    print("✅ 授权成功！Token 已保存到 .gmail_token.json")
    print("   现在可以运行 check_gmail.py 来检查邮件")

if __name__ == '__main__':
    authorize_gmail()
