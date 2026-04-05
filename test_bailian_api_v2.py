#!/usr/bin/env python3
"""
测试百炼 API 可用性 - 修复版
"""
import requests
import json
import os
from datetime import datetime

# 百炼 API 配置
BAILIAN_URL = "https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation"

def test_bailian_api(api_key):
    """测试百炼 API 连接"""
    print(f"\n🔍 测试百炼 API...")
    
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }
    
    # 使用正确的模型名称
    models = ["qwen-turbo", "qwen-plus", "qwen-max"]
    
    for model in models:
        print(f"\n  🤖 测试模型: {model}")
        
        data = {
            "model": model,
            "input": {
                "messages": [
                    {"role": "user", "content": "你好"}
                ]
            },
            "parameters": {}
        }
        
        try:
            response = requests.post(BAILIAN_URL, headers=headers, json=data, timeout=10)
            
            if response.status_code == 200:
                print(f"    ✅ 连接成功")
                result = response.json()
                output = result.get('output', {}).get('text', '')
                print(f"    📊 响应: {output[:100]}")
                return True
            elif response.status_code == 400:
                error = response.json().get('error', {})
                code = error.get('code', '')
                message = error.get('message', '')
                
                if 'model' in message and 'not supported' in message:
                    print(f"    ⚠️ 模型不支持，尝试下一个...")
                    continue
                else:
                    print(f"    ❌ 请求失败 (HTTP 400)")
                    print(f"    📝 错误: {message}")
                    return False
            elif response.status_code == 429:
                print(f"    ⚠️ 配额已用完 (HTTP 429)")
                error_msg = response.json().get('error', {}).get('message', 'Unknown')
                print(f"    📝 错误: {error_msg}")
                return False
            else:
                print(f"    ❌ 连接失败 (HTTP {response.status_code})")
                print(f"    📝 错误: {response.text[:200]}")
                return False
        except Exception as e:
            print(f"    ❌ 异常: {str(e)[:100]}")
            return False
    
    print(f"\n  ❌ 所有模型均不支持")
    return False

def check_env_file():
    """检查 .env 文件中的百炼配置"""
    env_file = os.path.expanduser("~/.openclaw/workspace/.env")
    
    print("📁 检查 .env 文件...")
    
    if not os.path.exists(env_file):
        print("  ❌ .env 文件不存在")
        return None
    
    with open(env_file, 'r') as f:
        content = f.read()
    
    # 查找百炼 API Key
    import re
    bailian_match = re.search(r'BAILIAN_API_KEY\s*=\s*["\']?([^\s"\']+)["\']?', content)
    
    if bailian_match:
        print("  ✅ 找到 BAILIAN_API_KEY")
        return bailian_match.group(1)
    else:
        print("  ⚠️ 未找到百炼 API Key")
        return None

if __name__ == "__main__":
    print("="*60)
    print("🔍 百炼 API 可用性检查（修复版）")
    print("="*60)
    print(f"⏰ 检查时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # 检查 .env 文件
    api_key = check_env_file()
    
    if not api_key:
        print("\n❌ 未找到有效的百炼 API Key")
        exit(1)
    
    print(f"\n🔑 API Key: {api_key[:10]}...{api_key[-10:]}")
    
    # 测试 API
    result = test_bailian_api(api_key)
    
    # 总结
    print("\n" + "="*60)
    print("📊 检查结果总结")
    print("="*60)
    
    if result:
        print("✅ 百炼 API 可用")
        print("\n💡 您可以使用以下模型:")
        print("  - qwen-turbo")
        print("  - qwen-plus")
        print("  - qwen-max")
    else:
        print("❌ 百炼 API 不可用")
        print("\n💡 建议:")
        print("  1. 检查 API Key 是否正确")
        print("  2. 检查账户余额是否充足")
        print("  3. 等待配额重置（如果是月度配额）")
        print("  4. 使用其他 AI 服务（如 Gemini、OpenRouter）")
    
    print("\n✅ 检查完成")
