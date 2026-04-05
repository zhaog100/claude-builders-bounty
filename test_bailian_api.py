#!/usr/bin/env python3
"""
测试百炼 API 可用性
"""
import requests
import json
import os
from datetime import datetime

# 百炼 API 配置
BAILIAN_BEIJING_URL = "https://coding.dashscope.aliyuncs.com/v1/chat/completions"
BAILIAN_SINGAPORE_URL = "https://singapore.dashscope.aliyuncs.com/v1/chat/completions"
BAILIAN_US_URL = "https://us.dashscope.aliyuncs.com/v1/chat/completions"

def test_bailian_api(api_key, url, region):
    """测试百炼 API 连接"""
    print(f"\n🔍 测试百炼 API ({region})...")
    
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }
    
    data = {
        "model": "qwen-plus",
        "messages": [
            {"role": "user", "content": "你好"}
        ],
        "max_tokens": 10
    }
    
    try:
        response = requests.post(url, headers=headers, json=data, timeout=10)
        
        if response.status_code == 200:
            print(f"  ✅ {region} - 连接成功")
            result = response.json()
            print(f"  📊 响应: {json.dumps(result, indent=2, ensure_ascii=False)[:200]}")
            return True
        elif response.status_code == 429:
            print(f"  ⚠️ {region} - 配额已用完 (HTTP 429)")
            error_msg = response.json().get('error', {}).get('message', 'Unknown')
            print(f"  📝 错误: {error_msg}")
            return False
        else:
            print(f"  ❌ {region} - 连接失败 (HTTP {response.status_code})")
            print(f"  📝 错误: {response.text[:200]}")
            return False
    except Exception as e:
        print(f"  ❌ {region} - 异常: {str(e)[:100]}")
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
    dashscope_match = re.search(r'DASHSCOPE_API_KEY\s*=\s*["\']?([^\s"\']+)["\']?', content)
    
    if bailian_match:
        print("  ✅ 找到 BAILIAN_API_KEY")
        return bailian_match.group(1)
    elif dashscope_match:
        print("  ✅ 找到 DASHSCOPE_API_KEY")
        return dashscope_match.group(1)
    else:
        print("  ⚠️ 未找到百炼 API Key")
        print("\n💡 需要添加以下配置到 .env 文件:")
        print('  BAILIAN_API_KEY="your-api-key-here"')
        print('  或')
        print('  DASHSCOPE_API_KEY="your-api-key-here"')
        return None

if __name__ == "__main__":
    print("="*60)
    print("🔍 百炼 API 可用性检查")
    print("="*60)
    print(f"⏰ 检查时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # 检查 .env 文件
    api_key = check_env_file()
    
    if not api_key:
        print("\n❌ 未找到有效的百炼 API Key")
        exit(1)
    
    print(f"\n🔑 API Key: {api_key[:10]}...{api_key[-10:]}")
    
    # 测试各个区域的 API
    regions = [
        ("北京", BAILIAN_BEIJING_URL),
        ("新加坡", BAILIAN_SINGAPORE_URL),
        ("美国", BAILIAN_US_URL)
    ]
    
    results = []
    for region_name, url in regions:
        result = test_bailian_api(api_key, url, region_name)
        results.append((region_name, result))
    
    # 总结
    print("\n" + "="*60)
    print("📊 检查结果总结")
    print("="*60)
    
    available_regions = [r for r, status in results if status]
    unavailable_regions = [r for r, status in results if not status]
    
    if available_regions:
        print(f"✅ 可用区域: {', '.join(available_regions)}")
    
    if unavailable_regions:
        print(f"❌ 不可用区域: {', '.join(unavailable_regions)}")
    
    if not available_regions:
        print("\n⚠️ 所有区域均不可用")
        print("\n💡 建议:")
        print("  1. 检查 API Key 是否正确")
        print("  2. 检查账户余额是否充足")
        print("  3. 等待配额重置（如果是月度配额）")
        print("  4. 考虑使用其他 AI 服务（如 OpenRouter）")
    
    print("\n✅ 检查完成")
