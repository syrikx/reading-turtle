"""
init_crawl_conditions.py
------------------------
📘 초기화 스크립트
- 기존 crawl_conditions 테이블 삭제 후 새로 생성
- hs6 테이블을 참조하여 HS2 / HS4 / HS6 코드 계층 자동 생성
- 5개국 × 2019.05~2025.10 조건 자동 등록
"""

import psycopg2
from datetime import date
from dateutil.relativedelta import relativedelta

# ========================
# 🔧 DB 설정
# ========================
DB = dict(
    host="localhost",
    database="trade2",
    user="trade_user2",
    password="ares82",
    port=5432,
)


# ========================
# 🧩 테이블 초기화
# ========================
def recreate_table(cur):
    print("🧹 기존 crawl_conditions 테이블 제거 중...")
    cur.execute("DROP TABLE IF EXISTS crawl_conditions CASCADE;")

    print("🧱 새 테이블 생성 중...")
    cur.execute("""
        CREATE TABLE crawl_conditions (
            id SERIAL PRIMARY KEY,
            country TEXT NOT NULL,
            month_str TEXT NOT NULL,
            hs_code TEXT NOT NULL,
            level INT NOT NULL,
            done BOOLEAN DEFAULT FALSE,
            last_crawled TIMESTAMP,
            created_at TIMESTAMP DEFAULT NOW(),
            CONSTRAINT unique_condition UNIQUE (country, month_str, hs_code)
        );
    """)


# ========================
# 🧩 데이터 생성 로직
# ========================
def generate_conditions(conn):
    cur = conn.cursor()
    countries = ["SOUTH KOREA", "CHINA", "JAPAN", "UNITED STATES", "SINGAPORE"]
    start_date = date(2019, 5, 1)
    end_date = date(2025, 10, 1)
    total_inserted = 0

    print("🚀 조건 생성 시작...")
    for country in countries:
        d = start_date
        while d <= end_date:
            month_str = d.strftime("%Y.%m")

            # HS2
            cur.execute("""
                INSERT INTO crawl_conditions (country, month_str, hs_code, level)
                SELECT %s, %s, DISTINCT hs2, 2 FROM hs6
                ON CONFLICT DO NOTHING;
            """, (country, month_str))

            # HS4
            cur.execute("""
                INSERT INTO crawl_conditions (country, month_str, hs_code, level)
                SELECT %s, %s, DISTINCT hs4, 4 FROM hs6
                ON CONFLICT DO NOTHING;
            """, (country, month_str))

            # HS6
            cur.execute("""
                INSERT INTO crawl_conditions (country, month_str, hs_code, level)
                SELECT %s, %s, hs6, 6 FROM hs6
                ON CONFLICT DO NOTHING;
            """, (country, month_str))

            d += relativedelta(months=1)
            conn.commit()
            total_inserted += cur.rowcount
            print(f"  ✅ {country} {month_str} 처리 완료")

    cur.close()
    print(f"🎉 전체 데이터 생성 완료 — 총 {total_inserted} 항목 삽입됨")


# ========================
# 📊 결과 요약
# ========================
def show_summary(conn):
    cur = conn.cursor()
    print("\n📊 생성 결과 요약:")

    cur.execute("SELECT COUNT(*) FROM crawl_conditions;")
    total = cur.fetchone()[0]
    print(f"  총 {total:,} 개 조건 생성됨")

    cur.execute("""
        SELECT level, COUNT(*) 
        FROM crawl_conditions 
        GROUP BY level ORDER BY level;
    """)
    for level, cnt in cur.fetchall():
        print(f"  - Level {level}: {cnt:,} 개")

    cur.close()


# ========================
# 🏁 실행
# ========================
if __name__ == "__main__":
    print("⚙️ crawl_conditions 초기화 시작...\n")

    conn = psycopg2.connect(**DB)
    cur = conn.cursor()

    recreate_table(cur)
    conn.commit()

    generate_conditions(conn)
    show_summary(conn)

    conn.close()
    print("\n✅ 모든 작업 완료!")
