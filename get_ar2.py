import asyncio
import csv
import os
import random
import re
import psycopg2
from playwright.async_api import async_playwright

# ===== DB 설정 =====
DB_CONFIG = {
    "host": "localhost",
    "database": "readingturtle",
    "user": "turtle_user",
    "password": "ares82",
    "port": 5432
}

BATCH_SIZE = 100
PROGRESS_FILE = "progress.csv"
FAILED_FILE = "failed.csv"
TEST_ISBN = "9781368071635"

# ===== DB 관련 =====
def get_books_with_isbn():
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
                    WHERE table_name='books' AND column_name='ar_quiz_no'
                ) THEN
                    ALTER TABLE books ADD COLUMN ar_quiz_no VARCHAR(20);
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
        print("✅ 컬럼 확인 완료 (필요 시 자동 추가됨)")
    except Exception as e:
        print(f"❌ 컬럼 추가 중 오류: {e}")


def update_book_info(isbn, ar_quiz_no, ar_level, lexile):
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()
        cur.execute("""
            UPDATE books
            SET ar_quiz_no = %s,
                ar_level = %s,
                lexile = %s
            WHERE isbn = %s
        """, (ar_quiz_no, ar_level, lexile, isbn))
        conn.commit()
        cur.close()
        conn.close()
        print(f"💾 {isbn} 업데이트 완료 (Quiz={ar_quiz_no}, Level={ar_level}, Lexile={lexile})")
    except Exception as e:
        print(f"⚠️ DB 업데이트 오류 ({isbn}): {e}")


# ===== CSV 관리 =====
def load_progress():
    if not os.path.exists(PROGRESS_FILE):
        return set()
    with open(PROGRESS_FILE, "r", encoding="utf-8") as f:
        return set(row[0] for row in csv.reader(f))


def save_progress(isbn):
    with open(PROGRESS_FILE, "a", encoding="utf-8", newline="") as f:
        csv.writer(f).writerow([isbn])


def save_failed(isbn):
    with open(FAILED_FILE, "a", encoding="utf-8", newline="") as f:
        csv.writer(f).writerow([isbn])


async def human_delay(min_s=1.0, max_s=3.0):
    await asyncio.sleep(min_s + random.random() * (max_s - min_s))


# ===== AR BookFinder (첫 1회만 UserType 선택) =====
async def get_ar_info(page, isbn, first_time=False):
    try:
        if first_time:
            print("🌐 첫 실행 - Student 선택 페이지 진입")
            await page.goto("https://www.arbookfind.com/UserType.aspx?RedirectURL=%2fdefault.aspx")
            await page.get_by_role("radio", name="Student").check()
            await page.get_by_role("button", name="Submit").click()
        else:
            await page.goto("https://www.arbookfind.com/default.aspx")

        await page.wait_for_selector("#ctl00_ContentPlaceHolder1_txtKeyWords", timeout=10000)
        await page.fill("#ctl00_ContentPlaceHolder1_txtKeyWords", isbn)
        await page.get_by_role("button", name="Search").click()
        await page.wait_for_selector("td.book-detail", timeout=1000)

        details = await page.locator("td.book-detail").all_inner_texts()
        full_text = " ".join(details)

        quiz_match = re.search(r"AR Quiz No\.\s*(\d+)", full_text)
        ar_quiz_no = quiz_match.group(1) if quiz_match else None

        bl_match = re.search(r"BL:\s*([0-9.]+)", full_text)
        ar_level = bl_match.group(1) if bl_match else None

        print(f"🎯 {isbn} → Quiz={ar_quiz_no}, Level={ar_level}")
        return ar_quiz_no, ar_level

    except Exception as e:
        print(f"⚠️ AR 처리 오류 ({isbn}): {e}")
        return None, None


# ===== Lexile Hub (지금은 비활성화) =====
async def get_lexile_info(page, isbn):
    try:
        await page.goto("https://hub.lexile.com/find-a-book/search", timeout=30000)
        await page.wait_for_selector("input[name='searchTerm']", timeout=5000)
        await page.fill("input[name='searchTerm']", isbn)
        await page.keyboard.press("Enter")
        await page.wait_for_timeout(2000)
        body = await page.content()
        m = re.search(r"\b\d{2,4}L\b", body)
        lexile_text = m.group(0) if m else None
        print(f"📗 {isbn} Lexile: {lexile_text}")
        return lexile_text
    except Exception as e:
        print(f"⚠️ Lexile 처리 오류 ({isbn}): {e}")
        return None


# ===== 배치 처리 =====
async def process_batch(batch, ar_page, lexile_page):
    first = True
    for isbn in batch:
        try:
            lexile = None  # 기본값 지정 (Lexile 비활성 시)
            ar_quiz_no, ar_level = await get_ar_info(ar_page, isbn, first_time=first)
            first = False
            await human_delay(0.5, 1.0)
            # ✅ ar_level이 None이면 실패 처리
            if ar_level is None:
                print(f"⚠️ {isbn} → AR Level이 None — 실패 처리")
                save_failed(isbn)
                continue
            update_book_info(isbn, ar_quiz_no, ar_level, lexile)
            save_progress(isbn)
        except Exception as e:
            print(f"⚠️ {isbn} 처리 중 오류: {e}")
            save_failed(isbn)
        await human_delay(0.5, 1.0)


# ===== 메인 실행 =====
async def main():
    ensure_columns()
    all_isbn = get_books_with_isbn()
    done = load_progress()
    remaining = [i for i in all_isbn if i not in done]
    print(f"📚 DB에서 {len(all_isbn)}권 조회, 남은 {len(remaining)}권")

    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        ar_page = await browser.new_page()
        lexile_page = await browser.new_page()

        print(f"\n🔎 테스트 실행: {TEST_ISBN}")
        test_quiz, test_level = await get_ar_info(ar_page, TEST_ISBN, first_time=True)
        print(f"테스트 결과 → Quiz={test_quiz}, Level={test_level}")

        if not test_quiz and not test_level:
            print("❗ 테스트 실패 — 사이트 구조 변경 또는 차단일 수 있음. 종료합니다.")
            await browser.close()
            return
        else:
            print("✅ 테스트 성공 — 전체 실행 시작")

        for i in range(0, len(remaining), BATCH_SIZE):
            batch = remaining[i:i + BATCH_SIZE]
            print(f"\n🚀 배치 실행: {i+1} ~ {i+len(batch)} / {len(remaining)}")
            await process_batch(batch, ar_page, lexile_page)
            print(f"✅ 배치 완료: {i+len(batch)} / {len(remaining)}")

        await browser.close()

    print("\n🎉 모든 작업 완료 (AR Quiz + Level + Lexile 저장)")


if __name__ == "__main__":
    asyncio.run(main())
