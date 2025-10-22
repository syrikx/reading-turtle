#!/usr/bin/env python3
"""
대량 ISBN 처리용 배치 크롤러
CSV 파일에서 ISBN을 읽어와서 일괄 처리하는 버전
"""

import requests
import json
import csv
import pandas as pd
from pathlib import Path
import time
from datetime import datetime
import psycopg2
from db_config import DB_CONFIG

class BatchISBNCrawler:
    def __init__(self, phpsessid="28a5c6beff555d07b3c3fa1101cb8537"):
        """배치 ISBN 크롤러 초기화"""
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36',
            'Accept': '*/*',
            'Content-Type': 'application/json'
        })

        self.session.cookies.update({
            'PHPSESSID': phpsessid
        })

        self.url = "https://app.booktaco.com/teacher/quiz-preview/"
        self.results = []

        # DB 연결 설정
        self.db_config = DB_CONFIG
        
    def update_quiz_url_in_db(self, isbn, quiz_url):
        """DB의 quiz_url 컬럼 업데이트"""
        try:
            conn = psycopg2.connect(**self.db_config)
            cur = conn.cursor()

            cur.execute("""
                UPDATE books
                SET quiz_url = %s
                WHERE isbn = %s
            """, (quiz_url, isbn))

            conn.commit()
            updated = cur.rowcount
            cur.close()
            conn.close()

            return updated > 0

        except Exception as e:
            print(f"  ⚠️  DB 업데이트 오류: {e}")
            return False

    def process_single_isbn(self, isbn):
        """단일 ISBN 처리 및 DB 업데이트"""
        try:
            payload = {"isbn": str(isbn)}
            response = self.session.post(self.url, json=payload, timeout=30)

            result = {
                'isbn': isbn,
                'status_code': response.status_code,
                'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                'success': False,
                'quiz_url': None,
                'error_message': None,
                'db_updated': False
            }

            if response.status_code == 200:
                try:
                    content = response.json()
                    if content.get('status') == 'success':
                        quiz_url = content.get('quizURL')
                        if quiz_url:
                            result['success'] = True
                            result['quiz_url'] = quiz_url

                            # DB 업데이트
                            if self.update_quiz_url_in_db(isbn, quiz_url):
                                result['db_updated'] = True
                                print(f"✅ {isbn}: Success (DB updated)")
                            else:
                                print(f"⚠️  {isbn}: API success but DB update failed")
                        else:
                            result['error_message'] = "No quizURL in response"
                            print(f"❌ {isbn}: No quizURL found")
                    else:
                        result['error_message'] = f"API status: {content.get('status')}"
                        print(f"❌ {isbn}: API error - {content.get('status')}")
                except json.JSONDecodeError:
                    result['error_message'] = "Invalid JSON response"
                    print(f"❌ {isbn}: JSON decode error")
            else:
                result['error_message'] = f"HTTP {response.status_code}"
                print(f"❌ {isbn}: HTTP error {response.status_code}")

            return result

        except requests.exceptions.Timeout:
            return {
                'isbn': isbn,
                'status_code': None,
                'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                'success': False,
                'quiz_url': None,
                'error_message': 'Request timeout',
                'db_updated': False
            }
        except Exception as e:
            return {
                'isbn': isbn,
                'status_code': None,
                'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                'success': False,
                'quiz_url': None,
                'error_message': str(e),
                'db_updated': False
            }
    
    def process_isbn_list(self, isbn_list, delay=1.0, save_interval=10):
        """ISBN 목록 일괄 처리 및 DB 업데이트"""
        total = len(isbn_list)
        print(f"🚀 {total}개 ISBN 처리 시작 (지연: {delay}초)")
        print(f"💾 {save_interval}개마다 중간 저장 (로그용)")
        print("-" * 60)

        for i, isbn in enumerate(isbn_list, 1):
            print(f"[{i:4d}/{total}] Processing: {isbn}")

            result = self.process_single_isbn(isbn)
            self.results.append(result)

            # 중간 저장 (로그 목적)
            if i % save_interval == 0:
                self.save_progress(f"temp_results_{i}.csv")
                print(f"💾 중간 로그 저장: {i}개 완료")

            # 지연 (마지막 요청 제외)
            if i < total:
                time.sleep(delay)

        # 최종 통계
        successful = sum(1 for r in self.results if r['success'])
        db_updated = sum(1 for r in self.results if r.get('db_updated', False))
        failed = total - successful

        print("\n" + "=" * 60)
        print(f"📊 처리 완료!")
        print(f"✅ API 성공: {successful}개 ({successful/total*100:.1f}%)")
        print(f"💾 DB 업데이트: {db_updated}개 ({db_updated/total*100:.1f}%)")
        print(f"❌ 실패: {failed}개 ({failed/total*100:.1f}%)")

        return self.results
    
    def save_progress(self, filename):
        """진행 상황 저장"""
        if not self.results:
            return
        
        df = pd.DataFrame(self.results)
        df.to_csv(filename, index=False, encoding='utf-8')
    
    def save_final_results(self, base_filename="isbn_results"):
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
            
            # Quiz URL만 따로 저장
            quiz_file = f"quiz_urls_{timestamp}.csv"
            quiz_df = df_success[['isbn', 'quiz_url']].copy()
            quiz_df.columns = ['ISBN', 'Quiz_URL']
            quiz_df.to_csv(quiz_file, index=False, encoding='utf-8')
            print(f"🔗 Quiz URL: {quiz_file}")

def load_isbn_from_file(filename):
    """파일에서 ISBN 목록 로드"""
    path = Path(filename)

    if not path.exists():
        print(f"❌ 파일을 찾을 수 없습니다: {filename}")
        return []

    try:
        if path.suffix.lower() == '.csv':
            df = pd.read_csv(filename)
            # 첫 번째 컬럼을 ISBN으로 가정
            isbn_list = df.iloc[:, 0].astype(str).tolist()
        elif path.suffix.lower() == '.txt':
            with open(filename, 'r', encoding='utf-8') as f:
                isbn_list = [line.strip() for line in f if line.strip()]
        else:
            print(f"❌ 지원하지 않는 파일 형식: {path.suffix}")
            return []

        print(f"📖 {len(isbn_list)}개 ISBN을 {filename}에서 로드했습니다.")
        return isbn_list

    except Exception as e:
        print(f"❌ 파일 로드 오류: {e}")
        return []

def load_isbn_from_db(sql_query=None):
    """DB에서 SQL 쿼리로 ISBN 목록 로드

    Args:
        sql_query: SQL 쿼리문. None이면 기본 쿼리 사용.
                   쿼리는 반드시 isbn 컬럼을 포함해야 함.

    Returns:
        ISBN 문자열 리스트
    """
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

        # ISBN 목록 추출 (첫 번째 컬럼을 ISBN으로 가정)
        isbn_list = [str(row[0]) for row in rows if row[0]]

        print(f"📖 {len(isbn_list)}개 ISBN을 DB에서 로드했습니다.")
        return isbn_list

    except Exception as e:
        print(f"❌ DB 로드 오류: {e}")
        return []

# 사용 예제
if __name__ == "__main__":
    # 크롤러 생성
    crawler = BatchISBNCrawler()

    # ========================================
    # 방법 1: DB에서 SQL 쿼리로 ISBN 로드
    # ========================================

    # 기본 쿼리 사용 (firehawk 시리즈)
    isbn_list = load_isbn_from_db()

    # 또는 커스텀 쿼리 사용 예제:

    # 특정 시리즈만:
    # custom_query = """
    #     SELECT isbn FROM books
    #     WHERE LOWER(series) LIKE '%firehawk%'
    #     ORDER BY created_at
    # """
    # isbn_list = load_isbn_from_db(custom_query)

    # 특정 저자만:
    # custom_query = """
    #     SELECT isbn FROM books
    #     WHERE LOWER(author) LIKE '%rowling%'
    #     ORDER BY created_at
    # """
    # isbn_list = load_isbn_from_db(custom_query)

    # quiz_url이 없는 것만:
    # custom_query = """
    #     SELECT isbn FROM books
    #     WHERE quiz_url IS NULL
    #     ORDER BY created_at
    # """
    # isbn_list = load_isbn_from_db(custom_query)

    # ========================================
    # 방법 2: 파일에서 ISBN 로드
    # ========================================
    # isbn_list = load_isbn_from_file("isbn_list.csv")

    # ========================================
    # 방법 3: 직접 ISBN 리스트 입력
    # ========================================
    # isbn_list = [
    #     "1338122134",
    #     "9780439708180",
    #     "9780439139601"
    # ]

    # ISBN 목록이 없으면 종료
    if not isbn_list:
        print("❌ 처리할 ISBN이 없습니다.")
        exit(1)

    # 처리 실행
    results = crawler.process_isbn_list(
        isbn_list,
        delay=1.0,        # 1초 지연
        save_interval=10  # 10개마다 중간 저장
    )

    # 결과 저장
    crawler.save_final_results()
