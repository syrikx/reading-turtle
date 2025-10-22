#!/usr/bin/env python3
"""
Quiz 데이터를 PostgreSQL에 저장하는 스크립트
"""

import psycopg2
from db_config import DB_CONFIG
from fetch_quiz import fetch_quiz_data, extract_token_from_quiz_url

def save_quiz_to_db(isbn, quiz_data):
    """Quiz 데이터를 DB에 저장

    Args:
        isbn: ISBN
        quiz_data: fetch_quiz_data()에서 반환된 quiz 데이터

    Returns:
        (quiz_id, questions_inserted) 튜플
    """
    if not quiz_data:
        print(f"❌ {isbn}: Quiz 데이터가 없습니다.")
        return None, 0

    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()

        # 1. quizzes 테이블에 삽입 (또는 업데이트)
        title = quiz_data.get('title', '')

        # construct_data에서 문제 파싱
        import json
        questions = []
        if 'construct_data' in quiz_data:
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

        total_questions = len(questions)

        if total_questions == 0:
            print(f"❌ {isbn}: 문제가 없습니다.")
            return None, 0

        # quiz 삽입 (중복시 업데이트)
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

        # 3. quiz_questions 테이블에 삽입
        questions_inserted = 0
        for i, q in enumerate(questions, 1):
            cur.execute("""
                INSERT INTO quiz_questions (
                    quiz_id, question_number, question_text,
                    choice_1, choice_2, choice_3, choice_4,
                    correct_answer
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                quiz_id,
                i,
                q['question'],
                q['choices'][0],
                q['choices'][1],
                q['choices'][2],
                q['choices'][3],
                q['correct_answer']
            ))
            questions_inserted += 1

        conn.commit()
        cur.close()
        conn.close()

        print(f"✅ {isbn}: Quiz 저장 완료 (quiz_id={quiz_id}, {questions_inserted}개 문제)")
        return quiz_id, questions_inserted

    except Exception as e:
        print(f"❌ {isbn}: DB 저장 오류 - {e}")
        return None, 0

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

def batch_save_quizzes_from_db(sql_query=None, phpsessid="4511cb15de07c7859001864c589507ce"):
    """DB에서 조회한 ISBN들의 quiz를 일괄 저장

    Args:
        sql_query: ISBN을 조회할 SQL 쿼리 (None이면 quiz_url이 있는 모든 책)
        phpsessid: PHP 세션 ID
    """
    if sql_query is None:
        sql_query = """
            SELECT isbn FROM books
            WHERE quiz_url IS NOT NULL
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

        isbn_list = [row[0] for row in rows]
        total = len(isbn_list)

        print(f"📖 {total}개 ISBN을 조회했습니다.")
        print()

        if total == 0:
            print("⚠️  처리할 ISBN이 없습니다.")
            return

        # 일괄 처리
        success = 0
        failed = 0
        total_questions = 0

        for i, isbn in enumerate(isbn_list, 1):
            print(f"[{i:4d}/{total}] Processing: {isbn}")

            quiz_id, questions_inserted = fetch_and_save_quiz_by_isbn(isbn, phpsessid)

            if quiz_id:
                success += 1
                total_questions += questions_inserted
            else:
                failed += 1

        # 최종 통계
        print("\n" + "=" * 60)
        print(f"📊 처리 완료!")
        print(f"✅ 성공: {success}개 ({success/total*100:.1f}%)")
        print(f"❌ 실패: {failed}개 ({failed/total*100:.1f}%)")
        print(f"📝 총 문제 수: {total_questions}개")
        print("=" * 60)

    except Exception as e:
        print(f"❌ 오류: {e}")

if __name__ == "__main__":
    # ========================================
    # 사용 예제
    # ========================================

    # PHP 세션 ID
    PHPSESSID = "4511cb15de07c7859001864c589507ce"

    # 방법 1: 단일 ISBN 저장
    print("🎯 방법 1: 단일 ISBN 저장")
    print("=" * 80)
    fetch_and_save_quiz_by_isbn("1338122134", phpsessid=PHPSESSID)

    print("\n\n")

    # 방법 2: quiz_url이 있는 모든 책의 quiz 저장
    print("🎯 방법 2: quiz_url이 있는 모든 책 일괄 저장")
    print("=" * 80)

    # 전체 실행
    batch_save_quizzes_from_db(phpsessid=PHPSESSID)

    # 또는 특정 조건
    # custom_query = """
    #     SELECT isbn FROM books
    #     WHERE quiz_url IS NOT NULL
    #     AND LOWER(series) LIKE '%firehawk%'
    #     ORDER BY created_at
    # """
    # batch_save_quizzes_from_db(custom_query, phpsessid=PHPSESSID)
