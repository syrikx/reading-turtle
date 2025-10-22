#!/usr/bin/env python3
"""
ReadingTurtle 단어 데이터 크롤링 스크립트
- 각 ISBN별 단어 목록을 가져와서 word_lists 테이블에 저장
- 각 단어의 정의를 가져와서 word_definitions 테이블에 저장
- 비동기 처리로 200개씩 동시 처리
"""

import asyncio
import aiohttp
import psycopg2
from psycopg2.extras import execute_values
import json
from datetime import datetime
from typing import List, Dict, Optional
import sys

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
BATCH_SIZE = 200  # 동시 처리할 ISBN 수
WORD_BATCH_SIZE = 50  # 동시 처리할 단어 수

# 통계
stats = {
    'total_books': 0,
    'books_processed': 0,
    'books_with_words': 0,
    'total_words_in_lists': 0,
    'unique_words_saved': 0,
    'words_already_existed': 0,
    'errors': 0
}


def get_db_connection():
    """데이터베이스 연결 생성"""
    return psycopg2.connect(**DB_CONFIG)


def get_all_isbns() -> List[str]:
    """books 테이블에서 모든 ISBN 가져오기"""
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT isbn FROM books ORDER BY isbn")
    isbns = [row[0] for row in cursor.fetchall()]

    cursor.close()
    conn.close()

    return isbns


async def fetch_word_list(session: aiohttp.ClientSession, isbn: str) -> Optional[List[str]]:
    """특정 ISBN의 단어 목록 가져오기"""
    url = f"{API_BASE_URL}/teacher/manage-books/list-wordlist"
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Content-Type': 'application/json',
        'Cookie': f'PHPSESSID={PHPSESSID}'
    }
    payload = json.dumps({"isbn": isbn})

    try:
        async with session.post(url, headers=headers, data=payload, timeout=30) as response:
            if response.status == 200:
                data = await response.json()
                if data.get('status') == 'success':
                    return data.get('data', [])
            return None
    except Exception as e:
        print(f"❌ Error fetching word list for ISBN {isbn}: {e}")
        stats['errors'] += 1
        return None


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
                    print(f"   First 500 chars: {response_text[:500]}")

                try:
                    data = json.loads(response_text)
                    if debug:
                        print(f"   JSON parsed successfully")
                        print(f"   Keys: {list(data.keys())}")
                        print(f"   Full response: {json.dumps(data, indent=2, ensure_ascii=False)}")

                    if data.get('request') == 'success':
                        word_data = data.get('data', {})
                        return {
                            'word_id': word_data.get('WordID'),
                            'word': word_data.get('word'),
                            'definition': word_data.get('definition'),
                            'example_sentence': word_data.get('sentence')
                        }
                except json.JSONDecodeError as je:
                    if debug:
                        print(f"   ❌ JSON decode error: {je}")
                    raise
            return None
    except Exception as e:
        print(f"❌ Error fetching definition for word '{word}': {e}")
        stats['errors'] += 1
        return None


def word_definition_exists(cursor, word: str) -> bool:
    """단어 정의가 이미 DB에 있는지 확인"""
    cursor.execute("SELECT 1 FROM word_definitions WHERE word = %s", (word,))
    return cursor.fetchone() is not None


def save_word_definition(cursor, word_data: Dict):
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
        stats['errors'] += 1
        return False


def save_word_list(cursor, isbn: str, words: List[str]):
    """책의 단어 목록을 DB에 저장"""
    try:
        # 기존 데이터 삭제 (업데이트를 위해)
        cursor.execute("DELETE FROM word_lists WHERE isbn = %s", (isbn,))

        # 새 데이터 삽입
        data = [(isbn, word, idx + 1) for idx, word in enumerate(words)]
        execute_values(cursor, """
            INSERT INTO word_lists (isbn, word, word_order)
            VALUES %s
            ON CONFLICT (isbn, word) DO NOTHING
        """, data)

        return True
    except Exception as e:
        print(f"❌ Error saving word list for ISBN {isbn}: {e}")
        stats['errors'] += 1
        return False


async def process_words_batch(session: aiohttp.ClientSession, words: List[str], cursor, debug: bool = False) -> int:
    """단어 배치 처리 - 정의 가져오기"""
    tasks = []
    words_to_fetch = []

    # DB에 없는 단어만 필터링
    for word in words:
        if not word_definition_exists(cursor, word):
            words_to_fetch.append(word)
            # 디버그 모드일 때는 첫 3개만 디버그
            is_debug = debug and len(tasks) < 3
            tasks.append(fetch_word_definition(session, word, debug=is_debug))
        else:
            stats['words_already_existed'] += 1

    if not tasks:
        return 0

    # 비동기로 단어 정의 가져오기
    results = await asyncio.gather(*tasks)

    # DB에 저장
    saved_count = 0
    for word_data in results:
        if word_data and word_data['word_id']:
            if save_word_definition(cursor, word_data):
                saved_count += 1
                stats['unique_words_saved'] += 1

    return saved_count


async def process_isbn(session: aiohttp.ClientSession, isbn: str, cursor, debug: bool = False) -> bool:
    """단일 ISBN 처리"""
    # 1. 단어 목록 가져오기
    word_list = await fetch_word_list(session, isbn)

    if not word_list or len(word_list) == 0:
        print(f"⚠️  ISBN {isbn}: No words found")
        return False

    print(f"📚 ISBN {isbn}: {len(word_list)} words found")
    if debug:
        print(f"   Sample words: {word_list[:10]}")

    stats['books_with_words'] += 1
    stats['total_words_in_lists'] += len(word_list)

    # 2. 단어 목록 저장
    save_word_list(cursor, isbn, word_list)
    if debug:
        print(f"   ✅ Word list saved to DB")

    # 3. 단어 정의 가져오기 (배치 처리)
    unique_words = list(set(word_list))  # 중복 제거
    if debug:
        print(f"   Unique words: {len(unique_words)}")

    # 단어를 작은 배치로 나누어 처리
    for i in range(0, len(unique_words), WORD_BATCH_SIZE):
        batch = unique_words[i:i + WORD_BATCH_SIZE]
        if debug:
            print(f"   Processing word batch {i//WORD_BATCH_SIZE + 1}/{(len(unique_words)-1)//WORD_BATCH_SIZE + 1}")
        await process_words_batch(session, batch, cursor, debug=debug)
        await asyncio.sleep(0.1)  # API 부하 방지

    return True


async def process_isbn_batch(isbns: List[str], batch_num: int, total_batches: int):
    """ISBN 배치 처리"""
    print(f"\n{'='*60}")
    print(f"📦 Batch {batch_num}/{total_batches} - Processing {len(isbns)} ISBNs")
    print(f"{'='*60}")

    conn = get_db_connection()
    cursor = conn.cursor()

    async with aiohttp.ClientSession() as session:
        tasks = [process_isbn(session, isbn, cursor) for isbn in isbns]
        results = await asyncio.gather(*tasks)

        stats['books_processed'] += len(isbns)

        # 각 ISBN 처리 후 커밋
        conn.commit()

    cursor.close()
    conn.close()

    # 진행 상황 출력
    print(f"\n📊 Batch {batch_num} Complete:")
    print(f"   - Books processed: {stats['books_processed']}/{stats['total_books']}")
    print(f"   - Books with words: {stats['books_with_words']}")
    print(f"   - Total words in lists: {stats['total_words_in_lists']}")
    print(f"   - Unique words saved: {stats['unique_words_saved']}")
    print(f"   - Words already existed: {stats['words_already_existed']}")
    print(f"   - Errors: {stats['errors']}")


async def test_single_isbn():
    """테스트: 단일 ISBN 처리"""
    test_isbn = "9780399541582"

    print("="*60)
    print("🧪 TEST MODE - Single ISBN")
    print("="*60)
    print(f"📅 Start time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"📖 Test ISBN: {test_isbn}")
    print(f"⚙️  Word batch size: {WORD_BATCH_SIZE} words per batch")
    print()

    conn = get_db_connection()
    cursor = conn.cursor()

    async with aiohttp.ClientSession() as session:
        print("Starting test with detailed debugging...\n")
        await process_isbn(session, test_isbn, cursor, debug=True)
        conn.commit()

    cursor.close()
    conn.close()

    print("\n" + "="*60)
    print("🧪 TEST COMPLETED")
    print("="*60)
    print("📊 Test Statistics:")
    print(f"   - Books with words: {stats['books_with_words']}")
    print(f"   - Total words in lists: {stats['total_words_in_lists']}")
    print(f"   - Unique words saved: {stats['unique_words_saved']}")
    print(f"   - Words already existed: {stats['words_already_existed']}")
    print(f"   - Errors: {stats['errors']}")
    print("="*60)


async def main():
    """메인 함수"""
    print("="*60)
    print("🐢 ReadingTurtle Word Crawler Started")
    print("="*60)
    print(f"📅 Start time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"⚙️  Batch size: {BATCH_SIZE} ISBNs per batch")
    print(f"⚙️  Word batch size: {WORD_BATCH_SIZE} words per batch")
    print()

    # 1. 모든 ISBN 가져오기
    print("📖 Fetching all ISBNs from database...")
    isbns = get_all_isbns()
    stats['total_books'] = len(isbns)
    print(f"✅ Found {len(isbns)} books")

    if len(isbns) == 0:
        print("❌ No books found in database!")
        return

    # 2. ISBN을 배치로 나누기
    batches = [isbns[i:i + BATCH_SIZE] for i in range(0, len(isbns), BATCH_SIZE)]
    total_batches = len(batches)

    print(f"📦 Split into {total_batches} batches\n")

    # 3. 각 배치 처리
    start_time = datetime.now()

    for batch_num, batch in enumerate(batches, 1):
        try:
            await process_isbn_batch(batch, batch_num, total_batches)
        except Exception as e:
            print(f"❌ Error processing batch {batch_num}: {e}")
            stats['errors'] += 1
            continue

    # 4. 최종 통계
    end_time = datetime.now()
    duration = (end_time - start_time).total_seconds()

    print("\n" + "="*60)
    print("✅ CRAWLING COMPLETED")
    print("="*60)
    print(f"📅 End time: {end_time.strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"⏱️  Duration: {duration:.2f} seconds ({duration/60:.2f} minutes)")
    print()
    print("📊 Final Statistics:")
    print(f"   - Total books: {stats['total_books']}")
    print(f"   - Books processed: {stats['books_processed']}")
    print(f"   - Books with words: {stats['books_with_words']}")
    print(f"   - Total words in lists: {stats['total_words_in_lists']}")
    print(f"   - Unique words saved: {stats['unique_words_saved']}")
    print(f"   - Words already existed: {stats['words_already_existed']}")
    print(f"   - Total unique words: {stats['unique_words_saved'] + stats['words_already_existed']}")
    print(f"   - Errors: {stats['errors']}")
    print()
    print(f"⚡ Average speed: {stats['books_processed']/duration:.2f} books/second")
    print("="*60)


if __name__ == "__main__":
    try:
        # 테스트 모드 실행
        print("🧪 Running in TEST mode first...")
        asyncio.run(test_single_isbn())

        print("\n\n" + "="*60)
        print("⏸️  TEST COMPLETE - Ready for full crawl")
        print("="*60)
        print("Press ENTER to continue with full crawl, or Ctrl+C to exit...")
        input()

        # 통계 리셋
        stats['books_processed'] = 0
        stats['books_with_words'] = 0
        stats['total_words_in_lists'] = 0
        stats['unique_words_saved'] = 0
        stats['words_already_existed'] = 0
        stats['errors'] = 0

        # 전체 크롤링 실행
        asyncio.run(main())

    except KeyboardInterrupt:
        print("\n\n⚠️  Interrupted by user")
        print(f"📊 Partial Statistics:")
        print(f"   - Books processed: {stats['books_processed']}/{stats['total_books']}")
        print(f"   - Books with words: {stats['books_with_words']}")
        print(f"   - Unique words saved: {stats['unique_words_saved']}")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Fatal error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
