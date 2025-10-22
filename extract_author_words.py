import psycopg2
import re
from collections import Counter
from db_config import DB_CONFIG

def extract_words_with_frequency(column_name, min_frequency=3):
    """DB에서 특정 컬럼의 단어를 추출하고, 빈도수 기준으로 필터링

    Args:
        column_name: 'author' 또는 'series'
        min_frequency: 최소 빈도수
    """

    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()

    # 지정된 컬럼의 모든 데이터 가져오기 (중복 포함)
    query = f"""
        SELECT {column_name}
        FROM books
        WHERE {column_name} IS NOT NULL AND {column_name} != ''
    """
    cur.execute(query)

    rows = cur.fetchall()
    cur.close()
    conn.close()

    # 모든 단어의 빈도를 계산
    word_counter = Counter()

    for (value,) in rows:
        # 단어 분리: 공백, 하이픈, 마침표 등으로 분리
        # 특수문자 제거하고 순수 단어만 추출
        words = re.findall(r"[A-Za-z']+", value)

        for word in words:
            # 길이가 2 이상인 단어만 포함 (a, I 같은 단일 문자 제외)
            if len(word) >= 2:
                word_counter[word] += 1

    # 빈도수 기준으로 필터링하여 반환
    # min_frequency 이상 등장한 단어만 선택하고, 빈도순으로 정렬
    filtered_words = [(word, count) for word, count in word_counter.items()
                      if count >= min_frequency]
    filtered_words.sort(key=lambda x: (-x[1], x[0]))  # 빈도 내림차순, 같으면 알파벳순

    return filtered_words

def extract_author_words_with_frequency(min_frequency=3):
    """DB에서 모든 author의 단어를 추출하고, 빈도수 기준으로 필터링"""
    return extract_words_with_frequency('author', min_frequency)

def extract_series_words_with_frequency(min_frequency=3):
    """DB에서 모든 series의 단어를 추출하고, 빈도수 기준으로 필터링"""
    return extract_words_with_frequency('series', min_frequency)

if __name__ == "__main__":
    import sys

    # 명령행 인자: column_name min_freq max_words
    # 예: python3 extract_author_words.py author 10 300
    # 예: python3 extract_author_words.py series 5 200
    column_name = sys.argv[1] if len(sys.argv) > 1 else "author"
    min_freq = int(sys.argv[2]) if len(sys.argv) > 2 else 10
    max_words = int(sys.argv[3]) if len(sys.argv) > 3 else 500

    print(f"Extracting {column_name} words from database...")
    print(f"Min frequency: {min_freq}, Max words: {max_words}")
    print()

    word_freq_list = extract_words_with_frequency(column_name, min_frequency=min_freq)

    # 최대 개수만큼만 선택
    top_words = word_freq_list[:max_words]

    print(f"Total words with frequency >= {min_freq}: {len(word_freq_list)}")
    print(f"Selected top {len(top_words)} words")
    print()

    print(f"Top 50 most frequent {column_name} words:")
    for i, (word, count) in enumerate(top_words[:50], 1):
        print(f"{i:3d}. {word:20s} (appears {count:5d} times)")

    if len(top_words) > 50:
        print("\n...")
        print(f"\nLast 10 words in selection:")
        for i, (word, count) in enumerate(top_words[-10:], len(top_words)-9):
            print(f"{i:3d}. {word:20s} (appears {count:5d} times)")

    # Python 리스트 형식으로 출력 (단어만 추출)
    words_only = [word for word, count in top_words]

    print("\n" + "="*80)
    print("Python list format (copy this to import_to_postgres.py):")
    print("="*80)
    print(f"{column_name}_queries = [")

    # 한 줄에 10개씩 출력
    for i in range(0, len(words_only), 10):
        chunk = words_only[i:i+10]
        print("    " + ", ".join(f'"{word}"' for word in chunk) + ",")

    print("]")
    print()
    print(f"This will generate {len(words_only)} * 4 filters = {len(words_only) * 4} API requests")
