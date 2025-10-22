#!/usr/bin/env python3
"""
누락된 단어 정의 가져오기 스크립트
- missing_words.txt 파일의 단어들에 대해 정의를 가져와서 DB에 저장
"""

import asyncio
import aiohttp
import psycopg2
import json
from typing import Dict, Optional, List

# 데이터베이스 연결 정보
DB_CONFIG = {
    'dbname': 'booktaco',
    'user': 'booktaco_user',
    'password': 'ares82',
    'host': 'localhost',
    'port': 5432
}

# API 설정
API_BASE_URL = 'https://app.booktaco.com'
PHPSESSID = '2cf84d80dc03ed6e2aad72525f038e6a'
BATCH_SIZE = 50  # 동시 처리할 단어 수

# 통계
stats = {
    'total_words': 0,
    'words_processed': 0,
    'words_saved': 0,
    'words_failed': 0,
    'errors': []
}


def get_db_connection():
    """데이터베이스 연결 생성"""
    return psycopg2.connect(**DB_CONFIG)


def read_missing_words(filename: str) -> List[str]:
    """missing_words.txt 파일에서 단어 목록 읽기"""
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            words = [line.strip() for line in f if line.strip()]
        return words
    except Exception as e:
        print(f"❌ Error reading file {filename}: {e}")
        return []


async def fetch_word_definition(session: aiohttp.ClientSession, word: str, debug: bool = False) -> Optional[Dict]:
    """특정 단어의 정의 가져오기"""
    url = f"{API_BASE_URL}/api/get-word?action=word-definition"
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Content-Type': 'application/json',
        'Cookie': f'PHPSESSID={PHPSESSID}'
    }
    payload = json.dumps({"word": word})

    try:
        async with session.post(url, headers=headers, data=payload, timeout=30) as response:
            if debug:
                print(f"\n🔍 DEBUG - Word: '{word}'")
                print(f"   Status: {response.status}")
                print(f"   Content-Type: {response.headers.get('Content-Type')}")

            if response.status == 200:
                response_text = await response.text()

                if debug:
                    print(f"   Response length: {len(response_text)} characters")
                    print(f"   First 200 chars: {response_text[:200]}")

                try:
                    data = json.loads(response_text)
                    if debug:
                        print(f"   JSON parsed successfully")
                        print(f"   Keys: {list(data.keys())}")

                    if data.get('request') == 'success':
                        word_data = data.get('data', {})
                        return {
                            'word_id': word_data.get('WordID'),
                            'word': word_data.get('word'),
                            'definition': word_data.get('definition'),
                            'example_sentence': word_data.get('sentence')
                        }
                    else:
                        if debug:
                            print(f"   ⚠️  Request not successful: {data.get('request')}")
                except json.JSONDecodeError as je:
                    if debug:
                        print(f"   ❌ JSON decode error: {je}")
                    stats['errors'].append(f"{word}: JSON decode error")
            else:
                if debug:
                    print(f"   ⚠️  HTTP Status: {response.status}")
            return None
    except Exception as e:
        print(f"❌ Error fetching definition for word '{word}': {e}")
        stats['errors'].append(f"{word}: {str(e)}")
        return None


def save_word_definition(cursor, word_data: Dict) -> bool:
    """단어 정의를 DB에 저장"""
    try:
        cursor.execute("""
            INSERT INTO word_definitions (word_id, word, definition, example_sentence)
            VALUES (%s, %s, %s, %s)
            ON CONFLICT (word_id) DO UPDATE SET
                definition = EXCLUDED.definition,
                example_sentence = EXCLUDED.example_sentence,
                updated_at = CURRENT_TIMESTAMP
        """, (
            word_data['word_id'],
            word_data['word'],
            word_data['definition'],
            word_data['example_sentence']
        ))
        return True
    except Exception as e:
        print(f"❌ Error saving word definition for '{word_data['word']}': {e}")
        stats['errors'].append(f"{word_data['word']}: DB save error - {str(e)}")
        return False


async def process_words_batch(session: aiohttp.ClientSession, words: List[str], cursor, conn, debug: bool = False):
    """단어 배치 처리"""
    tasks = []

    for word in words:
        # 디버그 모드일 때는 첫 3개만 디버그
        is_debug = debug and len(tasks) < 3
        tasks.append(fetch_word_definition(session, word, debug=is_debug))

    # 비동기로 단어 정의 가져오기
    results = await asyncio.gather(*tasks)

    # DB에 저장
    for i, word_data in enumerate(results):
        stats['words_processed'] += 1

        if word_data and word_data.get('word_id') and word_data['word_id'] is not None:
            if save_word_definition(cursor, word_data):
                conn.commit()  # 각 단어마다 즉시 커밋
                stats['words_saved'] += 1
                print(f"✅ {stats['words_processed']}/{stats['total_words']}: {word_data['word']} (ID: {word_data['word_id']})")
            else:
                stats['words_failed'] += 1
                print(f"❌ {stats['words_processed']}/{stats['total_words']}: Failed to save {words[i]}")
        else:
            stats['words_failed'] += 1
            reason = "No WordID" if word_data and word_data.get('word_id') is None else "No data"
            print(f"⚠️  {stats['words_processed']}/{stats['total_words']}: {reason} for {words[i]}")


async def main():
    """메인 함수"""
    print("="*60)
    print("🐢 ReadingTurtle - Missing Words Fetcher")
    print("="*60)
    print()

    # 1. missing_words.txt 읽기
    print("📖 Reading missing_words.txt...")
    words = read_missing_words('missing_words.txt')

    if not words:
        print("❌ No words found in missing_words.txt!")
        return

    stats['total_words'] = len(words)
    print(f"✅ Found {len(words)} missing words")
    print()

    # 2. DB 연결
    conn = get_db_connection()
    cursor = conn.cursor()

    # 3. 단어를 배치로 나누어 처리
    batches = [words[i:i + BATCH_SIZE] for i in range(0, len(words), BATCH_SIZE)]
    total_batches = len(batches)

    print(f"📦 Processing {total_batches} batches ({BATCH_SIZE} words per batch)")
    print()

    async with aiohttp.ClientSession() as session:
        for batch_num, batch in enumerate(batches, 1):
            print(f"\n{'='*60}")
            print(f"📦 Batch {batch_num}/{total_batches} - {len(batch)} words")
            print(f"{'='*60}")

            await process_words_batch(session, batch, cursor, conn)

            # API 부하 방지를 위한 짧은 대기
            if batch_num < total_batches:
                await asyncio.sleep(0.5)

    cursor.close()
    conn.close()

    # 4. 최종 통계
    print("\n" + "="*60)
    print("✅ PROCESSING COMPLETED")
    print("="*60)
    print()
    print("📊 Final Statistics:")
    print(f"   - Total words: {stats['total_words']}")
    print(f"   - Words processed: {stats['words_processed']}")
    print(f"   - Words saved: {stats['words_saved']}")
    print(f"   - Words failed: {stats['words_failed']}")
    print(f"   - Success rate: {stats['words_saved']/stats['total_words']*100:.1f}%")

    if stats['errors']:
        print(f"\n⚠️  Errors ({len(stats['errors'])}):")
        for error in stats['errors'][:10]:  # 처음 10개만 표시
            print(f"   - {error}")
        if len(stats['errors']) > 10:
            print(f"   ... and {len(stats['errors']) - 10} more errors")

    print("="*60)


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n\n⚠️  Interrupted by user")
        print(f"📊 Partial Statistics:")
        print(f"   - Words processed: {stats['words_processed']}/{stats['total_words']}")
        print(f"   - Words saved: {stats['words_saved']}")
    except Exception as e:
        print(f"\n❌ Fatal error: {e}")
        import traceback
        traceback.print_exc()
