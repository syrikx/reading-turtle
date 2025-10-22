#!/usr/bin/env python3
"""
대량 ISBN 처리용 비동기 배치 크롤러
aiohttp를 사용하여 동시에 여러 요청을 병렬로 처리
"""

import asyncio
import aiohttp
import json
from datetime import datetime
import psycopg2
from psycopg2.extras import execute_values
from db_config import DB_CONFIG
import pandas as pd

class AsyncBatchISBNCrawler:
    def __init__(self, phpsessid="28a5c6beff555d07b3c3fa1101cb8537", concurrent_limit=200):
        """비동기 배치 ISBN 크롤러 초기화

        Args:
            phpsessid: PHP 세션 ID
            concurrent_limit: 동시 처리할 최대 요청 수
        """
        self.phpsessid = phpsessid
        self.concurrent_limit = concurrent_limit
        self.url = "https://app.booktaco.com/teacher/quiz-preview/"
        self.results = []
        self.db_config = DB_CONFIG

        # 요청 헤더
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36',
            'Accept': '*/*',
            'Content-Type': 'application/json'
        }

        # 쿠키
        self.cookies = {
            'PHPSESSID': phpsessid
        }

    async def process_single_isbn(self, session, isbn, semaphore):
        """단일 ISBN 비동기 처리

        Args:
            session: aiohttp ClientSession
            isbn: 처리할 ISBN
            semaphore: 동시 요청 수 제한용 세마포어
        """
        async with semaphore:  # 동시 요청 수 제한
            result = {
                'isbn': isbn,
                'status_code': None,
                'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                'success': False,
                'quiz_url': None,
                'error_message': None,
                'db_updated': False
            }

            try:
                payload = {"isbn": str(isbn)}

                async with session.post(
                    self.url,
                    json=payload,
                    timeout=aiohttp.ClientTimeout(total=30)
                ) as response:
                    result['status_code'] = response.status

                    if response.status == 200:
                        try:
                            content = await response.json()

                            if content.get('status') == 'success':
                                quiz_url = content.get('quizURL')
                                if quiz_url:
                                    result['success'] = True
                                    result['quiz_url'] = quiz_url
                                    print(f"✅ {isbn}: Success")
                                else:
                                    result['error_message'] = "No quizURL in response"
                                    print(f"❌ {isbn}: No quizURL")
                            else:
                                result['error_message'] = f"API status: {content.get('status')}"
                                print(f"❌ {isbn}: API error - {content.get('status')}")
                        except json.JSONDecodeError:
                            result['error_message'] = "Invalid JSON response"
                            print(f"❌ {isbn}: JSON decode error")
                    else:
                        result['error_message'] = f"HTTP {response.status}"
                        print(f"❌ {isbn}: HTTP error {response.status}")

            except asyncio.TimeoutError:
                result['error_message'] = 'Request timeout'
                print(f"❌ {isbn}: Timeout")
            except Exception as e:
                result['error_message'] = str(e)
                print(f"❌ {isbn}: {str(e)}")

            return result

    async def process_isbn_batch(self, isbn_list):
        """ISBN 목록을 비동기로 일괄 처리

        Args:
            isbn_list: 처리할 ISBN 리스트
        """
        total = len(isbn_list)
        print(f"🚀 {total}개 ISBN 비동기 처리 시작 (동시 처리: {self.concurrent_limit}개)")
        print("-" * 60)

        # 세마포어로 동시 요청 수 제한
        semaphore = asyncio.Semaphore(self.concurrent_limit)

        # aiohttp 세션 생성
        connector = aiohttp.TCPConnector(limit=self.concurrent_limit)
        async with aiohttp.ClientSession(
            headers=self.headers,
            cookies=self.cookies,
            connector=connector
        ) as session:
            # 모든 ISBN에 대한 태스크 생성
            tasks = [
                self.process_single_isbn(session, isbn, semaphore)
                for isbn in isbn_list
            ]

            # 모든 태스크 동시 실행
            self.results = await asyncio.gather(*tasks)

        # 통계 출력
        successful = sum(1 for r in self.results if r['success'])
        failed = total - successful

        print("\n" + "=" * 60)
        print(f"📊 API 처리 완료!")
        print(f"✅ 성공: {successful}개 ({successful/total*100:.1f}%)")
        print(f"❌ 실패: {failed}개 ({failed/total*100:.1f}%)")

        return self.results

    def update_db_batch(self):
        """성공한 결과를 DB에 일괄 업데이트"""
        successful_results = [r for r in self.results if r['success'] and r['quiz_url']]

        if not successful_results:
            print("⚠️  업데이트할 데이터가 없습니다.")
            return 0

        try:
            conn = psycopg2.connect(**self.db_config)
            cur = conn.cursor()

            # 일괄 업데이트 쿼리
            update_query = """
                UPDATE books
                SET quiz_url = data.quiz_url
                FROM (VALUES %s) AS data(isbn, quiz_url)
                WHERE books.isbn = data.isbn
            """

            # 데이터 준비
            values = [(r['isbn'], r['quiz_url']) for r in successful_results]

            # 일괄 업데이트 실행
            execute_values(cur, update_query, values, template="(%s, %s)")

            conn.commit()
            updated_count = cur.rowcount

            cur.close()
            conn.close()

            print(f"💾 DB 업데이트 완료: {updated_count}개")

            # 결과에 db_updated 플래그 설정
            for r in self.results:
                if r['success'] and r['quiz_url']:
                    r['db_updated'] = True

            return updated_count

        except Exception as e:
            print(f"❌ DB 업데이트 오류: {e}")
            return 0

    def save_progress(self, filename):
        """진행 상황 저장 (로그용)"""
        if not self.results:
            return

        df = pd.DataFrame(self.results)
        df.to_csv(filename, index=False, encoding='utf-8')
        print(f"💾 로그 저장: {filename}")

    def save_final_results(self, base_filename="isbn_results_async"):
        """최종 결과 저장"""
        if not self.results:
            print("❌ 저장할 결과가 없습니다.")
            return

        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')

        # 전체 결과 저장
        all_file = f"{base_filename}_all_{timestamp}.csv"
        df_all = pd.DataFrame(self.results)
        df_all.to_csv(all_file, index=False, encoding='utf-8')
        print(f"💾 전체 결과: {all_file}")

        # 성공한 결과만 저장
        successful_results = [r for r in self.results if r['success']]
        if successful_results:
            success_file = f"{base_filename}_success_{timestamp}.csv"
            df_success = pd.DataFrame(successful_results)
            df_success.to_csv(success_file, index=False, encoding='utf-8')
            print(f"✅ 성공 결과: {success_file}")

def load_isbn_from_db(sql_query=None):
    """DB에서 SQL 쿼리로 ISBN 목록 로드"""
    # 기본 쿼리: DB 삽입 시간 순서(created_at)로 모든 ISBN 조회
    if sql_query is None:
        sql_query = """
            SELECT isbn FROM books
            ORDER BY created_at ASC
        """

    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()

        print(f"📊 실행 중인 SQL 쿼리:")
        print("-" * 60)
        print(sql_query)
        print("-" * 60)

        cur.execute(sql_query)
        rows = cur.fetchall()
        cur.close()
        conn.close()

        # ISBN 목록 추출
        isbn_list = [str(row[0]) for row in rows if row[0]]

        print(f"📖 {len(isbn_list)}개 ISBN을 DB에서 로드했습니다.")
        return isbn_list

    except Exception as e:
        print(f"❌ DB 로드 오류: {e}")
        return []

async def main():
    """메인 실행 함수"""

    # ========================================
    # ISBN 로드
    # ========================================

    # 기본: 전체 books 테이블 (created_at 순서)
    isbn_list = load_isbn_from_db()

    # 또는 커스텀 쿼리:

    # quiz_url이 없는 것만:
    # custom_query = """
    #     SELECT isbn FROM books
    #     WHERE quiz_url IS NULL
    #     ORDER BY created_at
    # """
    # isbn_list = load_isbn_from_db(custom_query)

    # 특정 시리즈만:
    # custom_query = """
    #     SELECT isbn FROM books
    #     WHERE LOWER(series) LIKE '%firehawk%'
    #     ORDER BY created_at
    # """
    # isbn_list = load_isbn_from_db(custom_query)

    if not isbn_list:
        print("❌ 처리할 ISBN이 없습니다.")
        return

    # ========================================
    # 크롤러 실행
    # ========================================

    # 크롤러 생성 (동시 처리 수: 100개)
    # 서버 부하를 고려하여 50-200 사이로 조정 가능
    crawler = AsyncBatchISBNCrawler(concurrent_limit=100)

    start_time = datetime.now()

    # 비동기 처리 실행
    results = await crawler.process_isbn_batch(isbn_list)

    # DB 일괄 업데이트
    crawler.update_db_batch()

    end_time = datetime.now()
    duration = (end_time - start_time).total_seconds()

    # 최종 통계
    successful = sum(1 for r in results if r['success'])
    db_updated = sum(1 for r in results if r.get('db_updated', False))

    print("\n" + "=" * 60)
    print(f"⏱️  총 소요 시간: {duration:.2f}초")
    print(f"⚡ 처리 속도: {len(isbn_list)/duration:.1f} ISBN/초")
    print(f"✅ API 성공: {successful}개")
    print(f"💾 DB 업데이트: {db_updated}개")
    print("=" * 60)

    # 결과 저장 (로그용)
    crawler.save_final_results()

if __name__ == "__main__":
    # asyncio 이벤트 루프 실행
    asyncio.run(main())
