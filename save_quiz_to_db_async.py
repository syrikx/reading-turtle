#!/usr/bin/env python3
"""
Quiz 데이터를 PostgreSQL에 저장하는 비동기 스크립트
aiohttp를 사용하여 동시에 여러 요청을 병렬로 처리
"""

import asyncio
import aiohttp
import json
from datetime import datetime
from urllib.parse import urlparse, parse_qs
import psycopg2
from psycopg2.extras import execute_batch
from db_config import DB_CONFIG


def extract_token_from_quiz_url(quiz_url):
    """quiz_url에서 token 추출"""
    try:
        parsed = urlparse(quiz_url)
        query_params = parse_qs(parsed.query)
        token = query_params.get('token', [None])[0]
        return token
    except Exception as e:
        return None


async def fetch_quiz_data_async(session, token, semaphore, debug=False):
    """API에서 quiz 데이터 비동기 조회

    Args:
        session: aiohttp ClientSession
        token: quiz token
        semaphore: 동시 요청 수 제한용 세마포어
        debug: 디버그 모드

    Returns:
        quiz 데이터 딕셔너리 또는 None
    """
    async with semaphore:
        try:
            url = f"https://app.booktaco.com/api/get-data?token={token}&language=english-quiz"

            async with session.get(url, timeout=aiohttp.ClientTimeout(total=30)) as response:
                if debug:
                    print(f"   Status: {response.status}")
                    print(f"   Headers: {response.headers}")

                if response.status == 200:
                    try:
                        content_type = response.headers.get('Content-Type', '')
                        text = await response.text()

                        if debug:
                            print(f"   Content-Type: {content_type}")
                            print(f"   Response text (first 500 chars): {text[:500]}")

                        return json.loads(text)
                    except json.JSONDecodeError as e:
                        if debug:
                            print(f"   JSON decode error: {e}")
                        return None
                else:
                    if debug:
                        print(f"   Response text: {await response.text()}")
                    return None
        except Exception as e:
            if debug:
                print(f"   Exception: {e}")
            return None


def parse_quiz_data(quiz_data):
    """Quiz 데이터 파싱

    Args:
        quiz_data: API에서 받은 quiz 데이터

    Returns:
        (title, questions) 튜플
    """
    if not quiz_data:
        return None, []

    title = quiz_data.get('title', '')
    questions = []

    if 'construct_data' in quiz_data:
        try:
            construct_data = json.loads(quiz_data['construct_data'])
            raw_data = construct_data.get('data', [])

            for item in raw_data:
                if len(item) >= 6:
                    question = {
                        'question': item[1][0],
                        'correct_answer': item[0][0],
                        'choices': [
                            item[2][0],
                            item[3][0],
                            item[4][0],
                            item[5][0],
                        ]
                    }
                    questions.append(question)
        except Exception as e:
            pass

    return title, questions


async def process_single_isbn_async(session, isbn, quiz_url, semaphore, debug=False):
    """단일 ISBN의 quiz 데이터 비동기 조회

    Args:
        session: aiohttp ClientSession
        isbn: ISBN
        quiz_url: Quiz URL
        semaphore: 동시 요청 수 제한용 세마포어
        debug: 디버그 모드

    Returns:
        결과 딕셔너리
    """
    result = {
        'isbn': isbn,
        'success': False,
        'title': None,
        'questions': [],
        'error_message': None
    }

    try:
        # Token 추출
        token = extract_token_from_quiz_url(quiz_url)
        if not token:
            result['error_message'] = 'Token 추출 실패'
            if debug:
                print(f"❌ {isbn}: Token 추출 실패")
                print(f"   quiz_url: {quiz_url}")
            else:
                print(f"❌ {isbn}: Token 추출 실패")
            return result

        if debug:
            print(f"🔍 {isbn}: Token 추출 완료")
            print(f"   Token: {token[:50]}...")

        # Quiz 데이터 조회
        quiz_data = await fetch_quiz_data_async(session, token, semaphore, debug)

        if not quiz_data:
            result['error_message'] = 'Quiz 데이터 조회 실패'
            print(f"❌ {isbn}: Quiz 데이터 조회 실패")
            return result

        # 데이터 파싱
        title, questions = parse_quiz_data(quiz_data)

        if not questions:
            result['error_message'] = '문제가 없습니다'
            print(f"❌ {isbn}: 문제가 없습니다")
            return result

        result['success'] = True
        result['title'] = title
        result['questions'] = questions
        print(f"✅ {isbn}: {len(questions)}개 문제 조회 완료")
        return result

    except Exception as e:
        result['error_message'] = str(e)
        print(f"❌ {isbn}: {str(e)}")
        return result


async def fetch_all_quizzes_async(isbn_quiz_list, phpsessid="4511cb15de07c7859001864c589507ce", concurrent_limit=200):
    """모든 ISBN의 quiz를 비동기로 일괄 조회

    Args:
        isbn_quiz_list: [(isbn, quiz_url), ...] 리스트
        phpsessid: PHP 세션 ID
        concurrent_limit: 동시 처리할 최대 요청 수

    Returns:
        결과 리스트
    """
    total = len(isbn_quiz_list)
    print(f"🚀 {total}개 ISBN 비동기 처리 시작 (동시 처리: {concurrent_limit}개)")
    print("-" * 60)

    # 세마포어로 동시 요청 수 제한
    semaphore = asyncio.Semaphore(concurrent_limit)

    # 헤더 설정
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': 'application/json',
        'Cookie': f'PHPSESSID={phpsessid}'
    }

    # aiohttp 세션 생성 (쿠키를 헤더에 직접 포함)
    connector = aiohttp.TCPConnector(limit=concurrent_limit)
    async with aiohttp.ClientSession(
        headers=headers,
        connector=connector
    ) as session:
        # 모든 ISBN에 대한 태스크 생성
        tasks = [
            process_single_isbn_async(session, isbn, quiz_url, semaphore, debug=(len(isbn_quiz_list) == 1))
            for isbn, quiz_url in isbn_quiz_list
        ]

        # 모든 태스크 동시 실행
        results = await asyncio.gather(*tasks)

    # 통계 출력
    successful = sum(1 for r in results if r['success'])
    failed = total - successful

    print("\n" + "=" * 60)
    print(f"📊 API 처리 완료!")
    print(f"✅ 성공: {successful}개 ({successful/total*100:.1f}%)")
    print(f"❌ 실패: {failed}개 ({failed/total*100:.1f}%)")
    print("=" * 60)

    return results


def save_quizzes_to_db_batch(results):
    """성공한 quiz 결과를 DB에 일괄 저장

    Args:
        results: fetch_all_quizzes_async()의 결과 리스트

    Returns:
        저장된 개수
    """
    successful_results = [r for r in results if r['success'] and r['questions']]

    if not successful_results:
        print("⚠️  저장할 데이터가 없습니다.")
        return 0

    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()

        saved_count = 0
        total_questions_count = 0

        for result in successful_results:
            isbn = result['isbn']
            title = result['title']
            questions = result['questions']
            total_questions = len(questions)

            try:
                # 1. quizzes 테이블에 삽입 (중복시 업데이트)
                cur.execute("""
                    INSERT INTO quizzes (isbn, title, total_questions)
                    VALUES (%s, %s, %s)
                    ON CONFLICT (isbn)
                    DO UPDATE SET
                        title = EXCLUDED.title,
                        total_questions = EXCLUDED.total_questions,
                        updated_at = CURRENT_TIMESTAMP
                    RETURNING quiz_id
                """, (isbn, title, total_questions))

                quiz_id = cur.fetchone()[0]

                # 2. 기존 문제 삭제 (업데이트를 위해)
                cur.execute("DELETE FROM quiz_questions WHERE quiz_id = %s", (quiz_id,))

                # 3. quiz_questions 테이블에 일괄 삽입
                question_data = []
                for i, q in enumerate(questions, 1):
                    question_data.append((
                        quiz_id,
                        i,
                        q['question'],
                        q['choices'][0],
                        q['choices'][1],
                        q['choices'][2],
                        q['choices'][3],
                        q['correct_answer']
                    ))

                execute_batch(cur, """
                    INSERT INTO quiz_questions (
                        quiz_id, question_number, question_text,
                        choice_1, choice_2, choice_3, choice_4,
                        correct_answer
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                """, question_data)

                saved_count += 1
                total_questions_count += total_questions

            except Exception as e:
                print(f"❌ {isbn}: DB 저장 오류 - {e}")
                continue

        conn.commit()
        cur.close()
        conn.close()

        print(f"\n💾 DB 저장 완료!")
        print(f"✅ 저장된 Quiz: {saved_count}개")
        print(f"📝 저장된 문제: {total_questions_count}개")

        return saved_count

    except Exception as e:
        print(f"❌ DB 저장 오류: {e}")
        return 0


def load_isbn_quiz_from_db(sql_query=None):
    """DB에서 ISBN과 quiz_url 목록 로드

    Args:
        sql_query: SQL 쿼리 (None이면 quiz가 1인 모든 책)

    Returns:
        [(isbn, quiz_url), ...] 리스트
    """
    if sql_query is None:
        sql_query = """
            SELECT isbn, quiz_url FROM books
            WHERE quiz = 1
            AND quiz_url IS NOT NULL
            ORDER BY created_at
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

        isbn_quiz_list = [(row[0], row[1]) for row in rows if row[0] and row[1]]

        print(f"📖 {len(isbn_quiz_list)}개 ISBN을 DB에서 로드했습니다.")
        return isbn_quiz_list

    except Exception as e:
        print(f"❌ DB 로드 오류: {e}")
        return []


async def batch_save_quizzes_async(sql_query=None, phpsessid="4511cb15de07c7859001864c589507ce", concurrent_limit=200):
    """DB에서 조회한 ISBN들의 quiz를 비동기로 일괄 저장

    Args:
        sql_query: ISBN을 조회할 SQL 쿼리 (None이면 quiz가 1인 모든 책)
        phpsessid: PHP 세션 ID
        concurrent_limit: 동시 처리할 최대 요청 수
    """
    # 1. DB에서 ISBN 및 quiz_url 로드
    isbn_quiz_list = load_isbn_quiz_from_db(sql_query)

    if not isbn_quiz_list:
        print("⚠️  처리할 ISBN이 없습니다.")
        return

    total_count = len(isbn_quiz_list)
    batch_size = concurrent_limit  # 200개씩 배치 처리

    print()
    print(f"📦 배치 처리 방식: {batch_size}개씩 조회 후 즉시 저장")
    print()

    start_time = datetime.now()
    total_saved = 0
    total_successful = 0

    # 2. batch_size 단위로 나눠서 처리
    for i in range(0, total_count, batch_size):
        batch = isbn_quiz_list[i:i+batch_size]
        batch_num = (i // batch_size) + 1
        total_batches = (total_count + batch_size - 1) // batch_size

        print(f"📦 배치 [{batch_num}/{total_batches}]: {len(batch)}개 ISBN 처리 중...")
        print("-" * 60)

        # 비동기로 quiz 데이터 조회
        results = await fetch_all_quizzes_async(batch, phpsessid, concurrent_limit)

        # 즉시 DB에 저장
        saved_count = save_quizzes_to_db_batch(results)
        successful = sum(1 for r in results if r['success'])

        total_saved += saved_count
        total_successful += successful

        print(f"✅ 배치 [{batch_num}/{total_batches}] 완료: {saved_count}개 저장 (누적: {total_saved}개)")
        print()

    end_time = datetime.now()
    duration = (end_time - start_time).total_seconds()

    # 최종 통계
    print("\n" + "=" * 60)
    print(f"🎉 전체 처리 완료!")
    print("=" * 60)
    print(f"⏱️  총 소요 시간: {duration:.2f}초")
    print(f"⚡ 처리 속도: {total_count/duration:.1f} ISBN/초")
    print(f"✅ API 성공: {total_successful}개 / {total_count}개")
    print(f"💾 DB 저장: {total_saved}개")
    print(f"📊 성공률: {total_successful/total_count*100:.1f}%")
    print("=" * 60)


def fetch_and_save_quiz_by_isbn(isbn, phpsessid="4511cb15de07c7859001864c589507ce"):
    """ISBN으로 quiz를 조회하고 DB에 저장

    Args:
        isbn: ISBN
        phpsessid: PHP 세션 ID

    Returns:
        (quiz_id, questions_inserted) 튜플
    """
    try:
        # 1. books 테이블에서 quiz_url 조회
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()

        cur.execute("""
            SELECT isbn, title, quiz_url
            FROM books
            WHERE isbn = %s
        """, (isbn,))

        row = cur.fetchone()
        cur.close()
        conn.close()

        if not row:
            print(f"❌ {isbn}: books 테이블에 없습니다.")
            return None, 0

        isbn, title, quiz_url = row

        if not quiz_url:
            print(f"❌ {isbn}: quiz_url이 없습니다.")
            return None, 0

        # 2. Token 추출
        token = extract_token_from_quiz_url(quiz_url)
        if not token:
            print(f"❌ {isbn}: token 추출 실패")
            return None, 0

        # 3. Quiz 데이터 조회
        quiz_data = fetch_quiz_data(token, phpsessid)
        if not quiz_data:
            print(f"❌ {isbn}: quiz 데이터 조회 실패")
            return None, 0

        # 4. DB에 저장
        return save_quiz_to_db(isbn, quiz_data)

    except Exception as e:
        print(f"❌ {isbn}: 오류 - {e}")
        return None, 0



async def test_single_isbn_async(test_isbn="1338122134", phpsessid="4511cb15de07c7859001864c589507ce"):
    """단일 ISBN으로 비동기 처리 테스트

    Args:
        test_isbn: 테스트할 ISBN
        phpsessid: PHP 세션 ID

    Returns:
        테스트 성공 여부 (True/False)
    """
    print("=" * 80)
    print("🧪 비동기 처리 테스트 시작")
    print("=" * 80)
    print(f"테스트 ISBN: {test_isbn}")
    print()

    try:
        # DB에서 quiz_url 조회
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()

        cur.execute("""
            SELECT isbn, quiz_url FROM books
            WHERE isbn = %s AND quiz_url IS NOT NULL
        """, (test_isbn,))

        row = cur.fetchone()
        cur.close()
        conn.close()

        if not row:
            print(f"❌ 테스트 실패: ISBN {test_isbn}을 찾을 수 없거나 quiz_url이 없습니다.")
            return False

        isbn, quiz_url = row

        # 비동기 처리 테스트
        results = await fetch_all_quizzes_async([(isbn, quiz_url)], phpsessid, concurrent_limit=1)

        if not results or len(results) == 0:
            print(f"❌ 테스트 실패: 결과가 없습니다.")
            return False

        result = results[0]

        if result['success']:
            print()
            print(f"✅ 테스트 성공!")
            print(f"   - ISBN: {result['isbn']}")
            print(f"   - 제목: {result['title']}")
            print(f"   - 문제 수: {len(result['questions'])}개")
            print()

            # DB 저장 테스트
            saved = save_quizzes_to_db_batch([result])

            if saved > 0:
                print(f"✅ DB 저장 테스트 성공!")
                print()
                print("=" * 80)
                print("🎉 모든 테스트 통과! 대량 처리를 시작합니다.")
                print("=" * 80)
                print()
                return True
            else:
                print(f"❌ DB 저장 테스트 실패")
                return False
        else:
            print(f"❌ 테스트 실패: {result.get('error_message', 'Unknown error')}")
            return False

    except Exception as e:
        print(f"❌ 테스트 중 오류 발생: {e}")
        import traceback
        traceback.print_exc()
        return False


async def main():
    """메인 실행 함수"""

    # PHP 세션 ID
    PHPSESSID = "4511cb15de07c7859001864c589507ce"

    # ========================================
    # 1단계: 단일 ISBN 테스트
    # ========================================

    test_success = await test_single_isbn_async("1338122134", PHPSESSID)

    if not test_success:
        print()
        print("=" * 80)
        print("⚠️  테스트 실패로 인해 대량 처리를 중단합니다.")
        print("=" * 80)
        return

    # ========================================
    # 2단계: quiz가 1인 모든 책 일괄 저장
    # ========================================

    # 전체 실행 (quiz = 1인 모든 책)
    await batch_save_quizzes_async(phpsessid=PHPSESSID, concurrent_limit=200)

    # 또는 특정 조건:
    # custom_query = """
    #     SELECT isbn, quiz_url FROM books
    #     WHERE quiz = 1
    #     AND quiz_url IS NOT NULL
    #     AND LOWER(series) LIKE '%firehawk%'
    #     ORDER BY created_at
    # """
    # await batch_save_quizzes_async(custom_query, phpsessid=PHPSESSID, concurrent_limit=200)


if __name__ == "__main__":
    # asyncio 이벤트 루프 실행
    asyncio.run(main())
