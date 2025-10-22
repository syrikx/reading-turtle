import requests
import json
import psycopg2
from psycopg2.extras import execute_values
from datetime import datetime
import time
import string
from db_config import DB_CONFIG, COOKIES

# 세션 생성 및 쿠키 설정
session = requests.Session()
session.headers.update({
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36',
    'Accept': '*/*',
    'Content-Type': 'application/json'
})

# 쿠키 추가
session.cookies.set('PHPSESSID', COOKIES['PHPSESSID'], domain='app.booktaco.com', path='/')
session.cookies.set('user_session_id', COOKIES['user_session_id'], domain='app.booktaco.com', path='/')

# PostgreSQL 연결
def get_db_connection():
    return psycopg2.connect(**DB_CONFIG)

# 테이블 생성
def create_table():
    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        CREATE TABLE IF NOT EXISTS books (
            isbn VARCHAR(20) PRIMARY KEY,
            title TEXT,
            author TEXT,
            series TEXT,
            link TEXT,
            pages INTEGER,
            wordcnt VARCHAR(20),
            pub_year INTEGER,
            quiz INTEGER,
            vocab INTEGER,
            quiz_requests TEXT,
            lexile VARCHAR(20),
            type VARCHAR(50),
            img TEXT,
            book_locked BOOLEAN,
            featured INTEGER,
            relevance INTEGER,
            amazon_asin_code VARCHAR(20),
            amazon_exists INTEGER,
            bt_level FLOAT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)

    conn.commit()
    cur.close()
    conn.close()
    print("✓ Table 'books' created or already exists")

# 데이터 삽입 (중복 시 무시)
def insert_books(books_data):
    if not books_data:
        return 0

    conn = get_db_connection()
    cur = conn.cursor()

    # INSERT ... ON CONFLICT DO NOTHING으로 중복 무시
    insert_query = """
        INSERT INTO books (
            isbn, title, author, series, link, pages, wordcnt, pub_year,
            quiz, vocab, quiz_requests, lexile, type, img, book_locked,
            featured, relevance, amazon_asin_code, amazon_exists, bt_level
        ) VALUES %s
        ON CONFLICT (isbn) DO NOTHING
    """

    values = []
    for book in books_data:
        values.append((
            book.get('isbn'),
            book.get('title'),
            book.get('author'),
            book.get('series'),
            book.get('link'),
            book.get('pages'),
            book.get('wordcnt'),
            book.get('pub_year'),
            book.get('quiz'),
            book.get('vocab'),
            book.get('quiz_requests'),
            book.get('lexile'),
            book.get('type'),
            book.get('img'),
            book.get('book_locked'),
            book.get('featured'),
            book.get('relevance'),
            book.get('amazon_asin_code'),
            book.get('amazon_exists'),
            book.get('bt_level')
        ))

    execute_values(cur, insert_query, values)
    inserted_count = cur.rowcount

    conn.commit()
    cur.close()
    conn.close()

    return inserted_count

# API 요청 함수
def fetch_books(query, filter_type, search_type="title"):
    """
    search_type: "title" 또는 "author"
    """
    url = 'https://app.booktaco.com/search'
    payload = {
        "query": query,
        "type": [search_type],
        "filter": [filter_type],
        "limit": 9999,
        "offset": 0,
        "infiniteScroll": True,
        "studentSearch": False
    }

    try:
        response = session.post(url, json=payload)

        if response.status_code == 200:
            # HTML 태그 제거
            cleaned_text = response.text.replace("<span class='search-word'>", "").replace("</span>", "")
            data = json.loads(cleaned_text)

            if isinstance(data, list):
                return data
            else:
                return []
        else:
            print(f"✗ Error: Status code {response.status_code} for query='{query}', filter='{filter_type}'")
            return []

    except Exception as e:
        print(f"✗ Exception for query='{query}', filter='{filter_type}': {e}")
        return []

# 메인 실행
def main():
    print("=" * 80)
    print("ReadingTurtle Data Import to PostgreSQL")
    print("=" * 80)
    print()

    # 테이블 생성
    create_table()
    print()

    # 쿼리 문자: a-z (이미 완료)
    # queries = list(string.ascii_lowercase)

    # 학생용 도서 제목에 많이 포함되는 단어들 (추가 검증용)
    title_queries = [
        # 일반 단어
        "the", "and", "of", "to", "in", "is", "you", "that", "it", "for",
        "on", "with", "as", "was", "at", "be", "this", "have", "from", "or",
        "one", "had", "by", "but", "not", "what", "all", "were", "we", "when",
        "your", "can", "said", "there", "an", "which", "she", "do", "how", "their",

        # 스토리/동화 관련
        "story", "tales", "adventure", "magic", "world", "little", "big", "great",
        "mystery", "secret", "life", "time", "day", "night", "way", "new", "old",
        "book", "first", "last", "journey", "quest", "hero", "king", "queen",

        # 학습/교육 관련
        "learn", "guide", "beginner", "easy", "fun", "kids", "children", "young",
        "readers", "read", "reading", "level", "grade", "school", "student",

        # 인기 주제
        "dragon", "princess", "animal", "cat", "dog", "bear", "mouse", "rabbit",
        "fairy", "wizard", "pirate", "dinosaur", "robot", "space", "ocean", "forest",
        "family", "friend", "boy", "girl", "child", "baby", "mother", "father",

        # 형용사/감정
        "happy", "sad", "lost", "found", "brave", "wild", "silly", "funny",
        "scary", "beautiful", "amazing", "incredible", "wonderful", "fantastic"
    ]

    # 저자 이름에서 추출한 빈도수 높은 단어들 (최소 10회 이상 등장, 상위 300개)
    # 저자 기준으로 재검증하기 위한 용도 (소문자로 통일)
    author_queries = [
        "david", "john", "michael", "james", "mary", "lisa", "jennifer", "susan", "various", "sarah",
        "ann", "rebecca", "kate", "elizabeth", "nancy", "jane", "laura", "julie", "paul", "martin",
        "chris", "smith", "thomas", "robert", "berenstain", "matt", "patricia", "lee", "barbara", "katie",
        "anne", "megan", "emily", "ellen", "margaret", "scott", "steve", "heather", "jan", "linda",
        "murray", "brown", "karen", "mike", "rachel", "cynthia", "eric", "jim", "amy", "peter",
        "rigby", "grace", "mark", "jones", "dan", "william", "tom", "adam", "gail", "catherine",
        "richard", "jeff", "kelly", "simon", "george", "helen", "melissa", "anna", "anderson", "virginia",
        "ruth", "miller", "sally", "deborah", "arnold", "green", "brian", "jill", "sara", "christopher",
        "hamilton", "lynn", "mari", "alex", "erin", "jenny", "joanne", "judy", "robin", "kevin",
        "tim", "sue", "stephen", "taylor", "lauren", "emma", "johnson", "carolyn", "jonathan", "stephanie",
        "kathryn", "bill", "rose", "charles", "christine", "joan", "andrew", "nelson", "jon", "stine",
        "patrick", "hansen", "jessica", "suzanne", "jean", "martha", "stan", "schuh", "disney", "nick",
        "allan", "jake", "janet", "west", "dean", "carol", "diane", "matthew", "na", "dahl",
        "ryan", "davis", "hagan", "loh", "stilton", "valerie", "daniel", "alice", "ben", "steven",
        "marie", "jack", "maria", "gray", "katherine", "michelle", "stewart", "tony", "gary", "louise",
        "marcia", "meadows", "williams", "daisy", "andrea", "higgins", "jason", "kathleen", "shannon", "laurie",
        "julia", "wilson", "claire", "alexander", "maddox", "tracey", "christina", "jerry", "mayer", "frank",
        "jacqueline", "publishing", "rob", "joyce", "peterson", "holly", "natalie", "wendy", "who", "joseph",
        "debbie", "marc", "hq", "gordon", "tammy", "anita", "parker", "howard", "aaron", "hunter",
        "kim", "blake", "caroline", "gregory", "carl", "charlotte", "harris", "wallace", "sharon", "reynolds",
        "murphy", "beth", "bruce", "josh", "victoria", "geronimo", "herman", "thompson", "angela", "king",
        "pope", "dave", "van", "mattern", "pam", "sam", "lewis", "betsy", "moore", "pamela",
        "alison", "mercer", "bell", "kristin", "samantha", "todd", "anthony", "lawrence", "berger", "cari",
        "greg", "adler", "bob", "jackson", "wood", "chandler", "kelley", "meister", "sandra", "gutman",
        "judith", "joe", "liza", "sommer", "and", "henry", "keene", "rylant", "baker", "ian",
        "owen", "bobbie", "books", "cole", "alan", "pat", "walter", "cooper", "don", "lori",
        "connie", "benjamin", "dixon", "russell", "stone", "young", "cecilia", "joy", "stuart", "colleen",
        "meg", "joanna", "kay", "kalman", "liz", "morgan", "rustad", "walker", "philip", "robinson",
        "osborne", "rick", "rey", "gagne", "guillain", "jen", "kristen", "lois", "london", "ron",
        "molly", "jordan", "kimberly", "warner", "de", "o'connor", "dk", "isabel", "patterson", "black",
    ]

    # 시리즈 이름에서 추출한 빈도수 높은 단어들 (최소 5회 이상 등장, 상위 500개)
    # 시리즈 기준으로 재검증하기 위한 용도 (소문자로 통일)
    series_queries = [
        "the", "of", "and", "readers", "to", "world", "read", "science", "book",
        "books", "reading", "in", "my", "series", "animals", "library", "sports", "level", "animal",
        "big", "step", "first", "ser", "little", "none", "reader", "blastoff", "kids", "set",
        "american", "cat", "adventures", "stories", "history", "with", "rigby", "for", "early",
        "leveled", "phonics", "magic", "school", "life", "about", "america", "all", "on", "tales",
        "you", "amazing", "can", "into", "rookie", "super", "it", "our", "stem",
        "time", "graphic", "true", "biographies", "great", "let's", "fiction", "literacy", "ready",
        "at", "wild", "rosen", "community", "national", "nonfiction", "collins", "real", "mysteries", "young",
        "math", "how", "scholastic", "an", "collection", "stars", "hello", "children",
        "who", "social", "states", "baby", "what", "english", "highlights", "girl", "star",
        "inside", "adventure", "geographic", "studies", "steam", "out", "club", "your",
        "classics", "fun", "earth", "nature's", "space", "exploring",
        "pearson", "dogs", "graded", "girls", "orca", "story", "disney", "wars",
        "heroes", "planet", "dog", "nature", "machines", "friends", "street", "beginning",
        "picture", "people", "pm", "chapter", "mystery", "countries", "explore", "united", "war", "know",
        "discovery", "family", "chronicles", "was", "holidays", "discover", "rainbow", "look",
        "nancy", "torque", "by", "pet", "up", "around", "words", "red", "fairy",
        "go", "diary", "americans", "house", "stilton", "do", "we", "diaries", "spotlight",
        "guides", "me", "princess", "bolt", "pro", "learning", "scooby", "green", "lego", "dragon",
        "jake", "doo", "greatest", "women", "work", "press", "start", "superstars", "awesome", "from",
        "lightning", "fact", "nfl", "learn", "penguin", "junior", "military",
        "classic", "guide", "weather", "native", "pets", "maddox", "goosebumps", "puppy", "farm", "weird",
        "facts", "action", "cool", "stone", "best", "geronimo", "engineering", "sea", "drew", "epic",
        "find", "fairies", "is", "primary", "scary", "dk", "extreme", "secret", "bumba",
        "kingdom", "bus", "smart", "stepping", "top", "welcome", "backyard", "dinosaurs", "tree",
        "simple", "curious", "want", "black", "body", "living", "explorers", "kid", "high",
        "disasters", "north", "illustrated", "like", "places", "choose", "jobs", "new", "puffin",
        "dc", "mighty", "be", "field", "spot", "emergent", "eyewitness", "special", "cats", "checkerboard",
        "computer", "get", "that", "day", "source", "boxcar", "football", "athletes",
        "novel", "warriors", "bears", "favorite", "game", "rising", "teen", "ancient", "buddy", "monster",
        "things", "brown", "cycles", "bird", "easy", "katie", "st", "critter", "natural", "secrets",
        "food", "george", "academy", "files", "place", "sitter's", "amp", "technology", "trilogy",
        "earth's", "word", "world's", "beast", "city", "novels", "journeys", "careers", "dinosaur", "famous",
        "african", "boys", "clifford", "design", "galaxy", "close", "detective", "ii", "ocean",
        "berenstain", "blue", "pony", "wonder", "are", "libraries", "behind", "team", "jones",
        "modern", "quest", "scott", "bad", "legends", "forces", "grade", "it's", "rescue",
        "seedlings", "celebration", "dear", "hardy", "helpers", "second", "storybooks", "biography", "foresman", "minecraft",
        "presidents", "creatures", "scientists", "bear", "culture", "everyday", "money", "nba",
        "global", "major", "max", "infact", "bob", "chapters", "ever", "explorer", "mouse",
        "one", "making", "see", "cambridge", "haunted", "seasons", "unicorn", "batman", "character", "good",
        "grow", "just", "live", "mr", "teams", "makers", "ninja", "tech", "insects",
        "ladybird", "meet", "news", "fluency", "holiday", "xtreme", "or", "arthur", "lives",
        "monsters", "neighborhood", "where", "days", "usborne", "country", "hot", "love", "power", "soccer",
        "core", "forest", "language", "maverick", "snakes", "yourself", "families", "sight",
        "ultimate", "bitty", "century", "comics", "edition", "flying", "make", "grolier", "jack",
        "night", "terl", "itty", "last", "parks", "searchlight", "today", "why", "bugs", "content",
        "comet", "creepy", "smithsonian", "abdo", "happy", "league", "matters", "us",
        "bio", "franklin", "road", "symbols", "tale", "pilot", "really", "sing", "wouldn't",
        "common", "continents", "hank", "myths", "system", "advanced", "art", "bailey",
        "pop", "skills", "uk", "watch", "as", "getting", "harry", "plus", "boy",
        "firehawk",
    ]

    # 필터 타입: 4가지
    filters = ["under_69_pages", "over_69_pages", "fiction", "non-fiction"]

    # 제목, 저자, 시리즈 검색을 분리하여 처리
    total_fetched = 0
    total_inserted = 0

    # 총 요청 수 계산: (제목 쿼리 + 저자 쿼리 + 시리즈 쿼리) * 필터 수
    total_requests = (len(title_queries) + len(author_queries) + len(series_queries)) * len(filters)
    current_request = 0

    start_time = datetime.now()

    # 1. 제목으로 검색 (type="title")
    # print("=" * 80)
    # print("PHASE 1: Searching by TITLE")
    # print("=" * 80)
    # print()

    # for query in title_queries:
    #     for filter_type in filters:
    #         current_request += 1

    #         print(f"[{current_request}/{total_requests}] Fetching: type='title', query='{query}', filter='{filter_type}'")

    #         books = fetch_books(query, filter_type, search_type="title")

    #         if books:
    #             inserted = insert_books(books)
    #             total_fetched += len(books)
    #             total_inserted += inserted

    #             print(f"  → Fetched: {len(books)}, Inserted: {inserted} (Duplicates skipped: {len(books) - inserted})")
    #         else:
    #             print(f"  → No data returned")

    #         # API 과부하 방지를 위한 짧은 대기
    #         time.sleep(0.5)
    #         print()

    # 2. 저자로 검색 (type="author")
    print()
    print("=" * 80)
    print("PHASE 2: Searching by AUTHOR")
    print("=" * 80)
    print()

    for query in author_queries:
        for filter_type in filters:
            current_request += 1

            print(f"[{current_request}/{total_requests}] Fetching: type='author', query='{query}', filter='{filter_type}'")

            books = fetch_books(query, filter_type, search_type="author")

            if books:
                inserted = insert_books(books)
                total_fetched += len(books)
                total_inserted += inserted

                print(f"  → Fetched: {len(books)}, Inserted: {inserted} (Duplicates skipped: {len(books) - inserted})")
            else:
                print(f"  → No data returned")

            # API 과부하 방지를 위한 짧은 대기
            time.sleep(0.5)
            print()

    # 3. 시리즈로 검색 (type="series")
    print()
    print("=" * 80)
    print("PHASE 3: Searching by SERIES")
    print("=" * 80)
    print()

    for query in series_queries:
        for filter_type in filters:
            current_request += 1

            print(f"[{current_request}/{total_requests}] Fetching: type='series', query='{query}', filter='{filter_type}'")

            books = fetch_books(query, filter_type, search_type="series")

            if books:
                inserted = insert_books(books)
                total_fetched += len(books)
                total_inserted += inserted

                print(f"  → Fetched: {len(books)}, Inserted: {inserted} (Duplicates skipped: {len(books) - inserted})")
            else:
                print(f"  → No data returned")

            # API 과부하 방지를 위한 짧은 대기
            time.sleep(0.5)
            print()

    end_time = datetime.now()
    duration = (end_time - start_time).total_seconds()

    print("=" * 80)
    print("Import Complete!")
    print("=" * 80)
    print(f"Total requests: {total_requests}")
    print(f"Total books fetched: {total_fetched}")
    print(f"Total books inserted: {total_inserted}")
    print(f"Duplicates skipped: {total_fetched - total_inserted}")
    print(f"Duration: {duration:.2f} seconds")
    print("=" * 80)

if __name__ == "__main__":
    main()
