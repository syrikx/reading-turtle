import asyncio
import csv
import os
import psycopg2
from playwright.async_api import async_playwright

# ===== DB 설정 =====
DB_CONFIG = {
    "host": "localhost",
    "database": "booktaco",
    "user": "booktaco_user",
    "password": "ares82",
    "port": 5432
}

BATCH_SIZE = 100
PROGRESS_FILE = "progress.csv"
FAILED_FILE = "failed.csv"


# ===== DB 관련 =====
def get_books_with_isbn():
    """DB에서 ISBN 목록 조회"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()
        cur.execute("""
            SELECT isbn 
            FROM books
            WHERE isbn IS NOT NULL
            ORDER BY created_at
        """)
        rows = cur.fetchall()
        cur.close()
        conn.close()
        return [r[0] for r in rows if r[0]]
    except Exception as e:
        print(f"❌ DB 조회 오류: {e}")
        return []


def ensure_columns():
    """books 테이블에 필요한 컬럼 자동 추가"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()
        cur.execute("""
            DO $$
            BEGIN
                IF NOT EXISTS (
                    SELECT 1 FROM information_schema.columns 
                    WHERE table_name='books' AND column_name='ar_level'
                ) THEN
                    ALTER TABLE books ADD COLUMN ar_level VARCHAR(10);
                END IF;
                IF NOT EXISTS (
                    SELECT 1 FROM information_schema.columns 
                    WHERE table_name='books' AND column_name='ar_points'
                ) THEN
                    ALTER TABLE books ADD COLUMN ar_points VARCHAR(10);
                END IF;
                IF NOT EXISTS (
                    SELECT 1 FROM information_schema.columns 
                    WHERE table_name='books' AND column_name='lexile'
                ) THEN
                    ALTER TABLE books ADD COLUMN lexile VARCHAR(20);
                END IF;
            END
            $$;
        """)
        conn.commit()
        cur.close()
        conn.close()
        print("✅ AR + Lexile 컬럼 확인 완료 (필요 시 자동 추가됨)")
    except Exception as e:
        print(f"❌ 컬럼 추가 중 오류: {e}")


def update_book_info(isbn, ar_level, ar_points, lexile):
    """AR, Lexile 정보를 DB에 저장"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()
        cur.execute("""
            UPDATE books
            SET ar_level = %s,
                ar_points = %s,
                lexile = %s
            WHERE isbn = %s
        """, (ar_level, ar_points, lexile, isbn))
        conn.commit()
        cur.close()
        conn.close()
        print(f"💾 {isbn} 업데이트 완료 (AR {ar_level}, {ar_points}, Lexile {lexile})")
    except Exception as e:
        print(f"⚠️ DB 업데이트 오류 ({isbn}): {e}")


# ===== CSV 관리 =====
def load_progress():
    """이미 처리된 ISBN 목록 읽기"""
    if not os.path.exists(PROGRESS_FILE):
        return set()
    with open(PROGRESS_FILE, "r", encoding="utf-8") as f:
        return set(row[0] for row in csv.reader(f))


def save_progress(isbn):
    """처리 완료된 ISBN 저장"""
    with open(PROGRESS_FILE, "a", encoding="utf-8", newline="") as f:
        csv.writer(f).writerow([isbn])


def save_failed(isbn):
    """실패한 ISBN 저장"""
    with open(FAILED_FILE, "a", encoding="utf-8", newline="") as f:
        csv.writer(f).writerow([isbn])


# ===== Playwright 크롤러 =====
async def get_ar_info(page, isbn):
    """AR BookFinder"""
    try:
        await page.goto("https://www.arbookfind.com/", timeout=30000)
        await page.fill("#ctl00_ContentPlaceHolder1_txtSearch", isbn)
        await page.keyboard.press("Enter")
        await page.wait_for_timeout(2000)

        rows = await page.query_selector_all(".searchresulttitle")
        if not rows:
            return None, None
        await rows[0].click()
        await page.wait_for_timeout(1000)

        ar_level = await page.inner_text("#ctl00_ContentPlaceHolder1_ucBookDetail_lblBookLevel")
        ar_points = await page.inner_text("#ctl00_ContentPlaceHolder1_ucBookDetail_lblPoints")
        return ar_level, ar_points
    except Exception:
        return None, None


async def get_lexile_info(page, isbn):
    """Lexile Hub"""
    try:
        await page.goto("https://hub.lexile.com/find-a-book/search", timeout=30000)
        await page.fill("input[name='searchTerm']", isbn)
        await page.keyboard.press("Enter")
        await page.wait_for_timeout(2000)

        elements = await page.query_selector_all("span:has-text('Lexile:')")
        if not elements:
            return None
        text = await elements[0].inner_text()
        return text.replace("Lexile:", "").strip()
    except Exception:
        return None


# ===== 메인 =====
async def process_batch(batch, ar_page, lexile_page):
    """ISBN 배치 단위 처리"""
    for isbn in batch:
        try:
            ar_level, ar_points = await get_ar_info(ar_page, isbn)
            lexile = await get_lexile_info(lexile_page, isbn)
            update_book_info(isbn, ar_level, ar_points, lexile)
            save_progress(isbn)
        except Exception as e:
            print(f"⚠️ {isbn} 처리 중 오류: {e}")
            save_failed(isbn)
        await asyncio.sleep(2)  # 서버 부하 방지


async def main():
    ensure_columns()
    all_isbn = get_books_with_isbn()
    done = load_progress()
    remaining = [i for i in all_isbn if i not in done]

    print(f"📚 전체 {len(all_isbn)}권 중 {len(remaining)}권 남음")

    if not remaining:
        print("✅ 모든 ISBN 처리 완료")
        return

    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        ar_page = await browser.new_page()
        lexile_page = await browser.new_page()

        total = len(remaining)
        for i in range(0, total, BATCH_SIZE):
            batch = remaining[i:i+BATCH_SIZE]
            print(f"\n🚀 {i+1}~{i+len(batch)}번째 배치 실행 중...")
            await process_batch(batch, ar_page, lexile_page)
            print(f"✅ {i+len(batch)} / {total} 처리 완료")

        await browser.close()

    print("\n🎉 모든 작업 완료 (AR + Lexile + 로그 저장)")
    print(f"📁 진행로그: {PROGRESS_FILE}")
    print(f"⚠️ 실패로그: {FAILED_FILE}")


if __name__ == "__main__":
    asyncio.run(main())
