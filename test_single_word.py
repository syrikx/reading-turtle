#!/usr/bin/env python3
"""
단일 단어 테스트 스크립트 - API 응답 디버깅
"""

import asyncio
import aiohttp
import json

API_BASE_URL = 'https://app.booktaco.com'
PHPSESSID = '2cf84d80dc03ed6e2aad72525f038e6a'

async def test_word(word: str):
    """특정 단어 테스트"""
    url = f"{API_BASE_URL}/api/get-word?action=word-definition"
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Content-Type': 'application/json',
        'Cookie': f'PHPSESSID={PHPSESSID}'
    }
    payload = json.dumps({"word": word})

    print(f"\n{'='*60}")
    print(f"Testing word: '{word}'")
    print(f"{'='*60}")

    async with aiohttp.ClientSession() as session:
        async with session.post(url, headers=headers, data=payload, timeout=30) as response:
            print(f"Status: {response.status}")
            print(f"Content-Type: {response.headers.get('Content-Type')}")

            response_text = await response.text()
            print(f"Response length: {len(response_text)} characters")
            print(f"\nFull response:")
            print(response_text[:1000])

            try:
                data = json.loads(response_text)
                print(f"\n✅ JSON parsed successfully")
                print(f"Keys: {list(data.keys())}")
                print(f"\nFull JSON:")
                print(json.dumps(data, indent=2, ensure_ascii=False))
            except json.JSONDecodeError as e:
                print(f"\n❌ JSON decode error: {e}")

async def main():
    # 성공했다고 표시되었지만 실제로는 없는 단어들 테스트
    test_words = ['Accessible', 'amatory', 'ballon']

    for word in test_words:
        await test_word(word)
        await asyncio.sleep(1)

if __name__ == "__main__":
    asyncio.run(main())
