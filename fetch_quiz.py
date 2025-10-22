#!/usr/bin/env python3
"""
Quiz 데이터 조회 스크립트
quiz_url에서 token을 추출하여 quiz 문제와 정답을 가져옴
"""

import requests
import json
from urllib.parse import urlparse, parse_qs

def extract_token_from_quiz_url(quiz_url):
    """quiz_url에서 token 추출

    Args:
        quiz_url: /public_uploads/html5/quiz/1/index.html?token=...&language=... 형식

    Returns:
        token 문자열 또는 None
    """
    try:
        # URL 파싱
        parsed = urlparse(quiz_url)
        query_params = parse_qs(parsed.query)

        # token 추출
        token = query_params.get('token', [None])[0]
        return token
    except Exception as e:
        print(f"❌ Token 추출 오류: {e}")
        return None

def fetch_quiz_data(token, phpsessid="4511cb15de07c7859001864c589507ce"):
    """API에서 quiz 데이터 조회

    Args:
        token: quiz token
        phpsessid: PHP 세션 ID

    Returns:
        quiz 데이터 딕셔너리 또는 None
    """
    try:
        url = f"https://app.booktaco.com/api/get-data?token={token}&language=english-quiz"

        # 세션 생성 및 쿠키 설정
        session = requests.Session()
        session.cookies.set('PHPSESSID', phpsessid, domain='app.booktaco.com', path='/')

        # 헤더 설정
        session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Accept': 'application/json',
        })

        response = session.get(url, timeout=30)

        if response.status_code == 200:
            # JSON 파싱 시도
            try:
                return response.json()
            except json.JSONDecodeError:
                print(f"❌ JSON 파싱 오류")
                print(f"Content-Type: {response.headers.get('Content-Type')}")
                print(f"First 500 chars: {response.text[:500]}")
                return None
        else:
            print(f"❌ HTTP 오류: {response.status_code}")
            return None

    except Exception as e:
        print(f"❌ 요청 오류: {e}")
        return None

def print_quiz_data(quiz_data, isbn=None):
    """Quiz 데이터를 보기 좋게 출력

    Args:
        quiz_data: API에서 받은 quiz 데이터
        isbn: ISBN (선택)
    """
    if not quiz_data:
        print("❌ Quiz 데이터가 없습니다.")
        return

    print("=" * 80)
    if isbn:
        print(f"📚 ISBN: {isbn}")
    print("=" * 80)
    print()

    # 책 정보
    if 'title' in quiz_data:
        print(f"📖 제목: {quiz_data.get('title', 'N/A')}")
    if 'author' in quiz_data:
        print(f"✍️  저자: {quiz_data.get('author', 'N/A')}")

    print()
    print("-" * 80)
    print("❓ QUIZ QUESTIONS")
    print("-" * 80)
    print()

    # construct_data 필드에서 문제 파싱
    questions = []
    if 'construct_data' in quiz_data:
        try:
            construct_data = json.loads(quiz_data['construct_data'])
            # c2array 형식: data는 [문제수][6][1] 형태의 3차원 배열
            # data[i][0][0] = 정답, data[i][1][0] = 질문, data[i][2-5][0] = 보기들
            raw_data = construct_data.get('data', [])

            for item in raw_data:
                if len(item) >= 6:
                    question = {
                        'question': item[1][0],  # 질문
                        'correct_answer': item[0][0],  # 정답
                        'choices': [
                            item[2][0],  # 보기 1
                            item[3][0],  # 보기 2
                            item[4][0],  # 보기 3
                            item[5][0],  # 보기 4
                        ]
                    }
                    questions.append(question)
        except Exception as e:
            print(f"⚠️  construct_data 파싱 오류: {e}")

    # 일반적인 키에서도 시도
    if not questions:
        questions = quiz_data.get('questions', quiz_data.get('quiz', quiz_data.get('items', [])))

    if not questions:
        print("⚠️  문제를 찾을 수 없습니다.")
        print("전체 데이터 구조:")
        print(json.dumps(quiz_data, indent=2, ensure_ascii=False)[:2000])
        return

    for i, question in enumerate(questions, 1):
        print(f"[문제 {i}]")

        # 문제 텍스트 (여러 가능한 키 이름 시도)
        q_text = question.get('question', question.get('text', question.get('q', 'N/A')))
        print(f"Q: {q_text}")
        print()

        # 보기
        choices = question.get('choices', question.get('answers', question.get('options', [])))
        if choices:
            print("보기:")
            for j, choice in enumerate(choices, 1):
                # choice가 문자열인지 딕셔너리인지 확인
                if isinstance(choice, dict):
                    choice_text = choice.get('text', choice.get('answer', str(choice)))
                else:
                    choice_text = str(choice)
                print(f"  {j}. {choice_text}")
        print()

        # 정답
        correct = question.get('correct_answer', question.get('correct', question.get('answer', 'N/A')))
        print(f"✅ 정답: {correct}")
        print()
        print("-" * 80)
        print()

def get_quiz_from_url(quiz_url, isbn=None, phpsessid="4511cb15de07c7859001864c589507ce"):
    """quiz_url에서 token을 추출하고 quiz 데이터 조회 및 출력

    Args:
        quiz_url: quiz URL
        isbn: ISBN (선택)
        phpsessid: PHP 세션 ID
    """
    # Token 추출
    token = extract_token_from_quiz_url(quiz_url)

    if not token:
        print("❌ Token을 추출할 수 없습니다.")
        return None

    print(f"🔑 Token 추출 완료")
    print(f"Token: {token[:50]}...")
    print()

    # Quiz 데이터 조회
    quiz_data = fetch_quiz_data(token, phpsessid)

    if quiz_data:
        print_quiz_data(quiz_data, isbn)
        return quiz_data
    else:
        return None

def get_quiz_from_db(isbn, phpsessid="4511cb15de07c7859001864c589507ce"):
    """DB에서 ISBN으로 quiz_url 조회 후 quiz 데이터 가져오기

    Args:
        isbn: ISBN
        phpsessid: PHP 세션 ID
    """
    import psycopg2
    from db_config import DB_CONFIG

    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()

        cur.execute("""
            SELECT isbn, title, author, quiz_url
            FROM books
            WHERE isbn = %s
        """, (isbn,))

        row = cur.fetchone()
        cur.close()
        conn.close()

        if not row:
            print(f"❌ ISBN {isbn}을 찾을 수 없습니다.")
            return None

        isbn, title, author, quiz_url = row

        print(f"📚 DB에서 조회:")
        print(f"  ISBN: {isbn}")
        print(f"  제목: {title}")
        print(f"  저자: {author}")
        print()

        if not quiz_url:
            print("❌ quiz_url이 없습니다.")
            return None

        print(f"🔗 Quiz URL: {quiz_url}")
        print()

        return get_quiz_from_url(quiz_url, isbn, phpsessid)

    except Exception as e:
        print(f"❌ DB 조회 오류: {e}")
        return None

if __name__ == "__main__":
    # ========================================
    # 사용 예제
    # ========================================

    # PHP 세션 ID (필요시 변경)
    PHPSESSID = "4511cb15de07c7859001864c589507ce"

    # 방법 1: quiz_url 직접 사용
    sample_quiz_url = "/public_uploads/html5/quiz/1/index.html?token=P2zgCJSvYN_AiHsTeU_ba0Y0YlNxK3dOa1JWQmtqZVA2aXJpbnFZd1hhTmtzMHhDSCtzL2hPR1V4c0tSM3cyVkVxekRyQ0FkSFdjVy9YU2RrRWR1NzlzUTRwYkZIeHlCVFNCRjVJOHZzN3NRanI5bHhoNStEYzdzMmJRTk9ic09iYk4xOXdLanJCS0kxVmdGSVhPS2R0MnNtUFQwajFvd0RvR251VG91Tmd6ekllVHQxQVVGY1NFN0FvaEUrMmFwc0R3dkNjNlJadHBLM0hXR3lPMlZPbnpSNXBWOHlWN3gvaDB1bVJSSTlkd21SSlJHLzFhNEJOdE9GYVU9&language=english-quiz"

    print("🎯 방법 1: quiz_url 직접 사용")
    print("=" * 80)
    get_quiz_from_url(sample_quiz_url, isbn="1338122134", phpsessid=PHPSESSID)

    print("\n\n")

    # 방법 2: DB에서 ISBN으로 조회
    print("🎯 방법 2: DB에서 ISBN으로 조회")
    print("=" * 80)
    get_quiz_from_db("1338122134", phpsessid=PHPSESSID)
