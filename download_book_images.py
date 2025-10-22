#!/usr/bin/env python3
"""
책 표지 이미지를 비동기로 일괄 다운로드하는 스크립트
"""

import asyncio
import aiohttp
import psycopg2
from pathlib import Path
from db_config import DB_CONFIG

# 설정
BASE_URL = "https://app.booktaco.com"
DOWNLOAD_DIR = Path("/mnt/blockstorage/syrikx0/bookimg")
CONCURRENT_LIMIT = 50  # 동시 다운로드 수
BATCH_SIZE = 500  # 배치 크기

async def download_image(session, isbn, img_path, semaphore):
    """단일 이미지 다운로드

    Args:
        session: aiohttp ClientSession
        isbn: ISBN
        img_path: DB의 img 컬럼 값 (예: /bookimg/9781773212661.jpg?v=461)
        semaphore: 동시성 제한

    Returns:
        (isbn, success, message) 튜플
    """
    async with semaphore:
        try:
            # img_path에서 파일명 추출 (쿼리 파라미터 제거)
            if img_path:
                # /bookimg/9781773212661.jpg?v=461 -> 9781773212661.jpg
                filename = img_path.split('?')[0].split('/')[-1]
            else:
                # img_path가 없으면 ISBN 사용
                filename = f"{isbn}.jpg"

            download_url = f"{BASE_URL}/bookimg/{filename}"
            save_path = DOWNLOAD_DIR / filename

            # 이미 존재하는 파일은 스킵
            if save_path.exists():
                return isbn, True, "Already exists"

            async with session.get(download_url, timeout=aiohttp.ClientTimeout(total=30)) as response:
                if response.status == 200:
                    content = await response.read()

                    # 파일 저장
                    with open(save_path, 'wb') as f:
                        f.write(content)

                    return isbn, True, f"Downloaded ({len(content)} bytes)"
                else:
                    return isbn, False, f"HTTP {response.status}"

        except asyncio.TimeoutError:
            return isbn, False, "Timeout"
        except Exception as e:
            return isbn, False, str(e)

async def download_batch(books_data, concurrent_limit=CONCURRENT_LIMIT):
    """배치 단위로 이미지 다운로드

    Args:
        books_data: [(isbn, img_path), ...] 리스트
        concurrent_limit: 동시 다운로드 수

    Returns:
        [(isbn, success, message), ...] 리스트
    """
    semaphore = asyncio.Semaphore(concurrent_limit)

    connector = aiohttp.TCPConnector(limit=100)
    timeout = aiohttp.ClientTimeout(total=60)

    async with aiohttp.ClientSession(
        connector=connector,
        timeout=timeout,
        auto_decompress=True,
        headers={"Accept-Encoding": "identity"},
    ) as session:
        tasks = [
            download_image(session, isbn, img_path, semaphore)
            for isbn, img_path in books_data
        ]

        results = await asyncio.gather(*tasks)
        return results

def get_books_with_images():
    """DB에서 이미지가 있는 책 목록 조회

    Returns:
        [(isbn, img_path), ...] 리스트
    """
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()

        # img 컬럼이 있는 모든 책 조회
        cur.execute("""
            SELECT isbn, img
            FROM books
            WHERE img IS NOT NULL AND img != ''
            ORDER BY created_at
        """)

        rows = cur.fetchall()
        cur.close()
        conn.close()

        return rows

    except Exception as e:
        print(f"❌ DB 조회 오류: {e}")
        return []

def batch_download_images():
    """이미지 일괄 다운로드 (배치 처리)"""

    print("=" * 80)
    print("📸 책 표지 이미지 일괄 다운로드")
    print("=" * 80)
    print()

    # 다운로드 디렉토리 생성
    DOWNLOAD_DIR.mkdir(parents=True, exist_ok=True)
    print(f"📁 저장 경로: {DOWNLOAD_DIR}")
    print()

    # DB에서 책 목록 조회
    print("📊 DB에서 책 목록 조회 중...")
    books_data = get_books_with_images()
    total_count = len(books_data)

    if total_count == 0:
        print("⚠️  다운로드할 이미지가 없습니다.")
        return

    print(f"📖 총 {total_count:,}개 책의 이미지를 다운로드합니다.")
    print()

    # 배치 단위로 처리
    success_count = 0
    failed_count = 0
    skip_count = 0

    for batch_num in range(0, total_count, BATCH_SIZE):
        batch = books_data[batch_num:batch_num + BATCH_SIZE]
        batch_size = len(batch)
        batch_index = batch_num // BATCH_SIZE + 1
        total_batches = (total_count + BATCH_SIZE - 1) // BATCH_SIZE

        print(f"🔄 배치 {batch_index}/{total_batches} 처리 중 ({batch_size}개)...")

        # 비동기 다운로드 실행
        results = asyncio.run(download_batch(batch, CONCURRENT_LIMIT))

        # 결과 집계
        for isbn, success, message in results:
            if success:
                if message == "Already exists":
                    skip_count += 1
                else:
                    success_count += 1
                    print(f"  ✅ {isbn}: {message}")
            else:
                failed_count += 1
                print(f"  ❌ {isbn}: {message}")

        print(f"  배치 완료: 성공 {success_count}, 스킵 {skip_count}, 실패 {failed_count}")
        print()

    # 최종 통계
    print("=" * 80)
    print("📊 다운로드 완료!")
    print(f"✅ 성공: {success_count:,}개 ({success_count/total_count*100:.1f}%)")
    print(f"⏭️  스킵: {skip_count:,}개 ({skip_count/total_count*100:.1f}%)")
    print(f"❌ 실패: {failed_count:,}개 ({failed_count/total_count*100:.1f}%)")
    print(f"📁 저장 경로: {DOWNLOAD_DIR}")
    print("=" * 80)

if __name__ == "__main__":
    batch_download_images()
