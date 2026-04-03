#!/usr/bin/env python3
"""
OpenRouter 免费模型使用示例
创建时间: 2026-04-04 07:05 CST
"""

import os
import requests
import json

# 从环境变量读取 API Key
API_KEY = os.getenv('OPENROUTER_API_KEY')
BASE_URL = "https://openrouter.ai/api/v1"

def chat_completion(prompt, model="qwen/qwen3.6-plus:free"):
    """调用 OpenRouter Chat Completion API"""
    
    url = f"{BASE_URL}/chat/completions"
    
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }
    
    data = {
        "model": model,
        "messages": [
            {"role": "user", "content": prompt}
        ]
    }
    
    try:
        response = requests.post(url, headers=headers, json=data, timeout=30)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"❌ 错误: {e}")
        return None

def list_free_models():
    """列出所有免费模型"""
    
    url = f"{BASE_URL}/models"
    
    headers = {
        "Authorization": f"Bearer {API_KEY}"
    }
    
    try:
        response = requests.get(url, headers=headers, timeout=10)
        response.raise_for_status()
        data = response.json()
        
        models = data.get('data', [])
        free_models = [m for m in models if ':free' in m.get('id', '')]
        
        print(f"\n📊 免费模型列表（共 {len(free_models)} 个）:\n")
        
        for i, m in enumerate(free_models[:10], 1):
            model_id = m.get('id', 'unknown')
            name = m.get('name', 'Unknown')
            context = m.get('context_length', 'N/A')
            print(f"{i:2}. {model_id}")
            print(f"    名称: {name}")
            print(f"    上下文: {context:,} tokens\n")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ 错误: {e}")

if __name__ == "__main__":
    # 示例 1: 列出免费模型
    print("=" * 60)
    print("示例 1: 列出免费模型")
    print("=" * 60)
    list_free_models()
    
    # 示例 2: 调用免费模型
    print("=" * 60)
    print("示例 2: 调用免费模型")
    print("=" * 60)
    print("\n提示词: '介绍一下你自己，简短回答'\n")
    
    result = chat_completion("介绍一下你自己，简短回答")
    
    if result and 'choices' in result:
        content = result['choices'][0]['message']['content']
        model = result.get('model', 'unknown')
        usage = result.get('usage', {})
        
        print(f"✅ 模型: {model}")
        print(f"✅ 响应: {content}")
        print(f"✅ Token 使用: {usage.get('total_tokens', 'N/A')}")
        print(f"✅ 成本: $0.00 (免费)")
    else:
        print("❌ 调用失败")
        print(result)
